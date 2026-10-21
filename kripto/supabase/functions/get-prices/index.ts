import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.18.3";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const DEFAULT_TTL_SECONDS = 60;

serve(async (req) => {
  // CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    const coingeckoApiKey = Deno.env.get("COINGECKO_API_KEY");

    if (!supabaseUrl || !supabaseServiceRoleKey) {
      throw new Error("Supabase ortam değişkenleri eksik (SUPABASE_URL veya SUPABASE_SERVICE_ROLE_KEY).");
    }

    const supabase = createClient(supabaseUrl, supabaseServiceRoleKey);

    // 1. Desteklenen tüm coinleri assets tablosundan çek
    const { data: assets, error: assetsError } = await supabase
      .from("assets")
      .select("id, symbol, coingecko_id");

    if (assetsError) throw assetsError;
    if (!assets || assets.length === 0) {
      return new Response(JSON.stringify([]), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 200,
      });
    }

    // 2. Mevcut price_cache tablosunu sorgula
    const { data: cachedPrices, error: cacheError } = await supabase
      .from("price_cache")
      .select("asset_id, currency, price, change_24h, fetched_at");

    if (cacheError) throw cacheError;

    const now = Date.now();
    const ttlMs = DEFAULT_TTL_SECONDS * 1000;

    // Önbellek tüm varlıklar için taze mi kontrolü
    const isCacheFresh =
      cachedPrices &&
      cachedPrices.length >= assets.length * 2 && // Hem USD hem TRY
      cachedPrices.every((p) => {
        const fetchedAt = new Date(p.fetched_at).getTime();
        return now - fetchedAt < ttlMs;
      });

    if (isCacheFresh) {
      // Önbellek taze -> CoinGecko'ya gitmeden doğrudan önbellekten dön
      return new Response(JSON.stringify(cachedPrices), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 200,
      });
    }

    // 3. Önbellek bayat veya eksik -> Tüm coinleri TEK TOPLU İSTEKTE çek
    const ids = assets.map((a) => a.coingecko_id).join(",");
    const coingeckoUrl = `https://api.coingecko.com/api/v3/simple/price?ids=${ids}&vs_currencies=usd,try&include_24hr_change=true`;

    const fetchHeaders: Record<string, string> = {
      Accept: "application/json",
    };
    if (coingeckoApiKey) {
      fetchHeaders["x-cg-demo-api-key"] = coingeckoApiKey;
    }

    const cgResponse = await fetch(coingeckoUrl, { headers: fetchHeaders });
    if (!cgResponse.ok) {
      // API limit aşıldıysa veya hata varsa, elimizdeki son bilinen önbelleği dön
      if (cachedPrices && cachedPrices.length > 0) {
        return new Response(JSON.stringify(cachedPrices), {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
          status: 200,
        });
      }
      throw new Error(`CoinGecko API hatası: ${cgResponse.status} ${cgResponse.statusText}`);
    }

    const cgData = await cgResponse.json();
    const upsertRows = [];
    const timestamp = new Date().toISOString();

    for (const asset of assets) {
      const coinData = cgData[asset.coingecko_id];
      if (!coinData) continue;

      if (coinData.usd !== undefined) {
        upsertRows.push({
          asset_id: asset.id,
          currency: "USD",
          price: coinData.usd,
          change_24h: coinData.usd_24h_change ?? 0,
          fetched_at: timestamp,
        });
      }

      if (coinData.try !== undefined) {
        upsertRows.push({
          asset_id: asset.id,
          currency: "TRY",
          price: coinData.try,
          change_24h: coinData.try_24h_change ?? 0,
          fetched_at: timestamp,
        });
      }
    }

    // 4. price_cache tablosuna toplu upsert
    if (upsertRows.length > 0) {
      const { error: upsertError } = await supabase
        .from("price_cache")
        .upsert(upsertRows, { onConflict: "asset_id,currency" });

      if (upsertError) {
        console.error("Upsert hatası:", upsertError);
      }
    }

    return new Response(JSON.stringify(upsertRows), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    });
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error instanceof Error ? error.message : "Bilinmeyen hata" }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 500,
      }
    );
  }
});

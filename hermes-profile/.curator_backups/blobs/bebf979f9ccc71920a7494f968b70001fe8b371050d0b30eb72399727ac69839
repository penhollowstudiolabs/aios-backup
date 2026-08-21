# Adding vision to a Hermes profile (Mayumi 8/15)

Avi asked to add `google/gemini-2.5-flash` vision to Mayumi (VPS1/ilocos), who had
none. Same model Alyosha uses — one OpenRouter key, proven, never lite-tier.

## Step 1 — confirm she has none, find the config end
```bash
ssh ilocos 'grep -nE "auxiliary|vision" /root/.hermes/profiles/ilocos/config.yaml'
ssh ilocos 'grep -nE "^[a-z_]+:" /root/.hermes/profiles/ilocos/config.yaml | head'  # top-level keys
ssh ilocos 'tail -6 /root/.hermes/profiles/ilocos/config.yaml'  # confirm file ends at fallback_model
```

## Step 2 — append the block (config is a flat YAML, append after `fallback_model`)
```bash
ssh ilocos 'cat >> /root/.hermes/profiles/ilocos/config.yaml <<'"'"'EOF'"'"'

auxiliary:
  vision:
    provider: openrouter
    model: google/gemini-2.5-flash
EOF'
```

## Step 3 — validate YAML (careful: single-quote the python inline so SSH doesn't mangle it)
```bash
ssh ilocos 'python3 -c "import yaml; yaml.safe_load(open(\"/root/.hermes/profiles/ilocos/config.yaml\")); print(\"YAML OK\")"'
```
Pitfall: embedding the python one-liner in an outer single-quoted SSH string
mangles quotes — use escaped `\"` inside, or write a tiny script file first.

## Step 4 — restart the gateway
Direct `ssh ilocos 'systemctl restart hermes-gateway-ilocos.service'` is BLOCKED by
the gateway-restart guard (this SSH session is a child of your own gateway). Use
the one-shot `no_agent` cron workaround in SKILL.md. Service unit:
`hermes-gateway-ilocos.service`. Verify `systemctl is-active` → `active` + a NEW pid.

## Step 5 — log it in the durable record
Update the Mayumi row in
`Efforts/Captain-Avi-System/Model-Token-Usage-Tracking.md` (add the vision
model + date).

## Ordering consideration
If the target is mid-job (SP-API validation etc.), Avi's preference is to wait for
the run to finish before restarting — confirm timing with him.

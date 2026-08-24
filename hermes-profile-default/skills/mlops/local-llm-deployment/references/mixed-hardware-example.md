# Mixed-hardware planning example

## Reported devices

- **CPU VPS:** 4 AMD EPYC vCPUs, 16 GB RAM, no supported accelerator, ~181 GB free disk.
- **Windows laptop:** HP Spectre x360 15-df1xxx; Intel i7-10510U (4C/8T), 16 GB RAM, NVIDIA GeForce MX250 plus Intel UHD, substantial free SSD space.

## Correct outcome

Neither device is a high-performance local LLM host.

- The VPS is suitable for an always-on but slow **3–4B Q4 GGUF** fallback served with `llama.cpp`.
- The laptop is suitable for local interactive use with a GUI such as **LM Studio**, also using a 3–4B Q4 GGUF primarily on CPU. Low-VRAM graphics should not drive model sizing without a live VRAM check.
- Do not deploy vLLM to the CPU VPS.

## Useful workloads

- Offline/private drafting and rewriting
- De-identified summaries and structured transformations
- Short document cleanup
- Service/outage fallback

## Do not promise

- Frontier-grade reasoning
- Fast autonomous coding
- Large-context document processing
- High-throughput multi-user service

## Example user framing

"A local 3B-class model can rewrite a de-identified progress note into a parent-friendly update without sending it to an API. It is a private utility lane and offline fallback; cloud remains primary for complex work."

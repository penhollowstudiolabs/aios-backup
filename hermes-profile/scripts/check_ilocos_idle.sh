#!/bin/bash
echo "=== active ilocos hermes chat jobs ==="
ps -ef | grep -E "profile ilocos (chat|serve)" | grep -v grep | head
echo "=== if empty above, safe to restart ==="

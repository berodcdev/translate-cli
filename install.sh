#!/usr/bin/env bash
# =============================================================================
# install.sh — instalador completo do comando global `translate`
# =============================================================================
# Deixa o `translate` pronto pra usar de qualquer diretório. Diferente de um
# instalador "só avisa", este RESOLVE o que faltar (pedindo confirmação):
#
#   - Homebrew ....... se faltar, mostra como instalar (não instala sozinho)
#   - Ollama ......... instala via 'brew install ollama' se faltar
#   - servidor ....... sobe o Ollama se não estiver respondendo
#   - modelo ......... baixa com 'ollama pull' se faltar (~5 GB)
#   - symlink ........ linka `translate` em ~/bin e dá chmod +x
#   - PATH ........... avisa (com a linha exata pro ~/.zshrc) se ~/bin faltar
#
# Uso:
#   ./install.sh          # interativo: pergunta antes de instalar cada coisa
#   ./install.sh -y       # assume "sim" em tudo (não interativo)
#   ./install.sh -h       # ajuda
#
# Só depende de ferramentas do macOS + Homebrew pra instalar o Ollama.
# =============================================================================

set -euo pipefail

# --- Config / caminhos -------------------------------------------------------
DIR_PROJETO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORIGEM="$DIR_PROJETO/translate"
DESTINO_BIN="$HOME/bin"
DESTINO="$DESTINO_BIN/translate"
AUTO_SIM=false

# Lê o modelo do próprio script `translate`, pra não dessincronizar.
MODELO="$(grep -E '^MODELO=' "$ORIGEM" 2>/dev/null | head -1 | cut -d'"' -f2)"
MODELO="${MODELO:-aya-expanse}"

# --- Cores (só quando é terminal) --------------------------------------------
if [[ -t 1 ]]; then
  BOLD=$'\033[1m'; DIM=$'\033[2m'; GRN=$'\033[32m'; YEL=$'\033[33m'
  RED=$'\033[31m'; CYA=$'\033[36m'; RST=$'\033[0m'
else
  BOLD=""; DIM=""; GRN=""; YEL=""; RED=""; CYA=""; RST=""
fi
ok()    { echo "  ${GRN}✔${RST} $1"; }
aviso() { echo "  ${YEL}!${RST} $1"; }
erro()  { echo "  ${RED}✖${RST} $1" >&2; }
titulo(){ echo; echo "${BOLD}${CYA}==>${RST} ${BOLD}$1${RST}"; }
tem()   { command -v "$1" >/dev/null 2>&1; }

# --- ajuda -------------------------------------------------------------------
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  echo "Uso: ./install.sh [-y]"
  echo "  -y   assume 'sim' em todas as instalações (modo não interativo)"
  exit 0
fi
[[ "${1:-}" == "-y" || "${1:-}" == "--yes" ]] && AUTO_SIM=true

# --- confirma() — pergunta S/n; com -y ou sem terminal, responde sozinho -----
# Retorna 0 (sim) / 1 (não). Sem tty e sem -y: assume "não" (seguro).
confirma() {
  local prompt="$1" resp
  if [[ "$AUTO_SIM" == true ]]; then return 0; fi
  if [[ ! -t 0 ]]; then aviso "sem terminal interativo; pulei: $prompt"; return 1; fi
  read -r -p "    ${prompt} ${DIM}[S/n]${RST} " resp
  [[ -z "$resp" || "$resp" =~ ^[SsYy]$ ]]
}

echo "${BOLD}Instalador do translate${RST}"

# =============================================================================
# 1) Sanidade
# =============================================================================
if [[ ! -f "$ORIGEM" ]]; then
  erro "não achei o script 'translate' em $DIR_PROJETO"
  exit 1
fi

# =============================================================================
# 2) Ollama (instala via Homebrew se faltar)
# =============================================================================
titulo "Ollama"
if tem ollama; then
  ok "Ollama já instalado ($(command -v ollama))"
else
  aviso "Ollama não encontrado."
  if tem brew; then
    if confirma "Instalar o Ollama agora com 'brew install ollama'?"; then
      if brew install ollama; then
        ok "Ollama instalado."
      else
        erro "falha ao instalar o Ollama via Homebrew. Instale manualmente: https://ollama.com/download"
        exit 1
      fi
    else
      erro "Ollama é obrigatório. Instale e rode de novo: brew install ollama"
      exit 1
    fi
  else
    erro "Homebrew não encontrado — não dá pra instalar o Ollama automaticamente."
    echo "    Instale o Homebrew (https://brew.sh) e rode de novo, ou baixe o Ollama"
    echo "    direto de https://ollama.com/download"
    exit 1
  fi
fi

# =============================================================================
# 3) Servidor do Ollama (sobe se não estiver respondendo)
# =============================================================================
titulo "Servidor do Ollama"
if ollama list >/dev/null 2>&1; then
  ok "servidor respondendo."
else
  aviso "servidor não está respondendo; tentando subir..."
  if tem brew && brew services list 2>/dev/null | grep -q '^ollama'; then
    brew services start ollama >/dev/null 2>&1 || true
  else
    # Sobe em background e desgruda do terminal.
    nohup ollama serve >/dev/null 2>&1 &
  fi
  # Espera até ~10s pelo servidor ficar de pé.
  for _ in 1 2 3 4 5 6 7 8 9 10; do
    ollama list >/dev/null 2>&1 && break
    sleep 1
  done
  if ollama list >/dev/null 2>&1; then
    ok "servidor no ar."
  else
    erro "não consegui subir o servidor do Ollama. Abra outro terminal e rode: ollama serve"
    exit 1
  fi
fi

# =============================================================================
# 4) Modelo (baixa se faltar — atenção: ~5 GB)
# =============================================================================
titulo "Modelo '$MODELO'"
LISTA="$(ollama list 2>/dev/null || true)"
if grep -qE "^${MODELO}(:|[[:space:]]|$)" <<<"$LISTA"; then
  ok "modelo '$MODELO' já baixado."
else
  aviso "modelo '$MODELO' não está baixado (o download pode passar de 5 GB)."
  if confirma "Baixar agora com 'ollama pull $MODELO'?"; then
    if ollama pull "$MODELO"; then
      ok "modelo '$MODELO' baixado."
    else
      erro "falha ao baixar o modelo. Tente manualmente: ollama pull $MODELO"
      exit 1
    fi
  else
    aviso "sem o modelo o comando não traduz. Baixe depois com: ollama pull $MODELO"
  fi
fi

# =============================================================================
# 4b) python3 (usado pra falar com a API HTTP do Ollama)
# =============================================================================
titulo "python3"
if python3 -c 'pass' >/dev/null 2>&1; then
  ok "python3 disponível ($(command -v python3))."
else
  aviso "python3 não está funcional. Instale com: brew install python"
  aviso "(o comando usa só a stdlib do Python pra montar/ler o JSON da API)"
fi

# =============================================================================
# 5) Symlink em ~/bin + permissão de execução
# =============================================================================
titulo "Comando global"
mkdir -p "$DESTINO_BIN"
chmod +x "$ORIGEM"
ln -sf "$ORIGEM" "$DESTINO"
ok "linkado: $DESTINO ${DIM}->${RST} $ORIGEM"

# =============================================================================
# 6) ~/bin está no PATH?
# =============================================================================
case ":$PATH:" in
  *":$DESTINO_BIN:"*)
    ok "~/bin já está no PATH."
    ;;
  *)
    aviso "~/bin NÃO está no PATH. Adicione ao fim do seu ~/.zshrc:"
    echo
    echo "      ${BOLD}export PATH=\"\$HOME/bin:\$PATH\"${RST}"
    echo
    echo "      Depois: ${DIM}source ~/.zshrc${RST} (ou abra um terminal novo)"
    ;;
esac

# =============================================================================
# 7) Fim
# =============================================================================
echo
echo "${GRN}${BOLD}Pronto!${RST} Agora é só digitar '${BOLD}translate${RST}' de qualquer lugar."
echo "Ex.:  ${CYA}translate \"how are you\"${RST}"

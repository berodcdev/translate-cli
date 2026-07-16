# Roteiro do GIF de demonstração do `translate`, gerado com vhs.
#   Gerar:  vhs assets/demo.tape   (a partir da raiz do projeto)
#   Requer: vhs (brew install vhs) e o comando `translate` no PATH.
# Foco/gancho: tradutor OFFLINE de erros de terminal — teu código/erro não
# sai da máquina (nada de colar erro da empresa no ChatGPT/Google).

Output assets/demo.gif

Set Shell "bash"
Set FontSize 15
Set Width 1240
Set Height 650
Set Padding 24
Set TypingSpeed 55ms
Set Theme { "name": "alive-matrix", "background": "#0a0d0a", "foreground": "#c8e6c9", "black": "#0a0d0a", "red": "#ff5f5f", "green": "#39ff14", "yellow": "#f4f465", "blue": "#5fafff", "magenta": "#d787ff", "cyan": "#5fffd7", "white": "#e8f5e9", "brightBlack": "#5c6d5c", "brightRed": "#ff8787", "brightGreen": "#8bff6b", "brightYellow": "#ffff87", "brightBlue": "#87d7ff", "brightMagenta": "#ffafff", "brightCyan": "#afffff", "brightWhite": "#ffffff", "cursor": "#39ff14", "selection": "#1f3d1f" }

# --- Setup escondido: PATH, prompt limpo e pré-aquecimento do modelo --------
# cd pra um diretório temporário (fora de qualquer repo) pro `git status` do
# beat 1 errar de verdade. O PROMPT é literal, então o cd não muda o que aparece.
Hide
Type 'export PATH="$HOME/bin:$PATH"'  Enter
Type 'cd "$(mktemp -d)"'  Enter
Type "PS1='\[\033[92m\]~/projeto\[\033[0m\] \[\033[95m\]❯\[\033[0m\] '"  Enter
# Pré-aquece o modelo: a 1ª chamada carrega ~5 GB na RAM (~7s a frio) e, sem
# isso, atrasa o beat 1 e embola a saída dos seguintes. Escondido = não conta
# frame no GIF; o Sleep só cobre o load a frio.
Type 'translate -t en "aquecendo" >/dev/null 2>&1'  Enter
Sleep 15s
Type "clear"  Enter
Show

# --- Abertura: o gancho é OFFLINE + privacidade ------------------------------
Sleep 900ms
Type "# erro em inglês? traduz no terminal — 100% offline, teu código não vai pra nuvem"  Sleep 500ms  Enter
Sleep 1000ms

# Sleeps = latência quente medida (git ~2,5s / traceback ~4,8s / -t ~1,1s) +
# folga, pra tradução aparecer antes do vhs digitar o próximo comando.
# --- 1) O erro de git mais universal que existe (real, fora de repo) ---------
Type "git status 2>&1 | translate"  Sleep 400ms  Enter    # >>> AJUSTE AQUI
Sleep 4500ms

# --- 2) Traceback inteiro do Python: traduz a prosa, PRESERVA o código -------
Type "python3 -c 'print(1 + [])' 2>&1 | translate"  Sleep 400ms  Enter    # >>> AJUSTE AQUI
Sleep 7500ms

# --- 3) Import quebrado (typo clássico): ModuleNotFoundError traduzido -------
Type "python3 -c 'import requestz' 2>&1 | translate"  Sleep 400ms  Enter    # >>> AJUSTE AQUI
Sleep 6000ms

# --- 4) E também texto do dia a dia, com destino forçado (-t) ----------------
Type 'translate -t en "revisa meu PR quando puder, é rapidinho"'  Sleep 400ms  Enter    # >>> AJUSTE AQUI
Sleep 5000ms

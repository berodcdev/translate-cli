# Roteiro do GIF de demonstração do `translate`, gerado com vhs.
#   Gerar:  vhs assets/demo.tape   (a partir da raiz do projeto)
#   Requer: vhs (brew install vhs) e o comando `translate` no PATH.
# Foco/gancho: tradutor OFFLINE de erros de terminal — teu código/erro não
# sai da máquina (nada de colar erro da empresa no ChatGPT/Google).

Output assets/demo.gif

Set Shell "zsh"
Set FontFamily "MesloLGL Nerd Font Mono"
Set FontSize 20
Set Theme "Catppuccin Mocha"
Set Padding 30
Set Width 1420
Set Height 560
Set TypingSpeed 45ms

# --- Setup escondido: PATH, comentários interativos, prompt limpo ------------
# cd pra um diretório temporário (fora de qualquer repo) pro `git status` do
# beat 1 errar de verdade. O PROMPT é literal, então o cd não muda o que aparece.
Hide
Type 'export PATH="$HOME/bin:$PATH"'  Enter
Type 'setopt interactive_comments'  Enter
Type 'cd "$(mktemp -d)"'  Enter
Type "precmd_functions=(); RPROMPT=''; PROMPT='%F{147}~/projeto%f %F{219}❯%f '"  Enter
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

# Sleeps = latência quente medida (git 2,5s / traceback 4,8s / -t 1,1s) + folga,
# pra tradução aparecer antes do vhs digitar o próximo comando.
# --- 1) O erro de git mais universal que existe (real, fora de repo) ---------
Type "git status 2>&1 | translate"  Sleep 400ms  Enter
Sleep 4500ms

# --- 2) Traceback inteiro do Python: traduz a prosa, PRESERVA o código -------
Type "python3 -c 'print(1 + [])' 2>&1 | translate"  Sleep 400ms  Enter
Sleep 7500ms

# --- 3) E também texto do dia a dia, com destino forçado (-t) ----------------
Type 'translate -t en "revisa meu PR quando puder, é rapidinho"'  Sleep 400ms  Enter
Sleep 3500ms

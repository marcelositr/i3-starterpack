# ~/.bashrc
#-----------HEADER-------------------------------------------------------------|
# AUTOR             : Marcelo Trindade - @marcelositr - marcelost@riseup.net
# DATA-DE-CRIAÇÃO   : 2026-03-24
# PROGRAMA          : Marcelo Prompt Engine
# VERSÃO            : 1.2 (Security, Performance & Dynamic Alignment Edition)
# PEQUENA-DESCRIÇÃO : Motor de prompt dinâmico com integração GPG-Agent,
#                     Git, Containers e controle de tempo de execução.
#------------------------------------------------------------------------------|

#---------------------------------- TESTES ------------------------------------>
# Garante que o script só rode em terminais interativos.
case $- in
    *i*) ;;
    *) return ;;
esac
#--------------------------------- FIM-TESTES ---------------------------------<


#--------------------------------- CONSTANTES --------------------------------->
# Configurações do Histórico e Shell
HISTCONTROL=ignoreboth
HISTSIZE=10000
HISTFILESIZE=20000
shopt -s histappend
shopt -s checkwinsize

# --- GPG SSH AGENT CONFIG ---
if command -v gpgconf >/dev/null 2>&1; then
    export GPG_TTY=$(tty)
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
    gpg-connect-agent --no-autostart updatestartuptty /bye >/dev/null 2>&1
fi

# Tabela de Cores (Verifica se já existem para evitar alertas no 'source')
[[ -z "$C_RESET" ]]  && readonly C_RESET="\[\e[0m\]"
[[ -z "$C_GREEN" ]]  && readonly C_GREEN="\[\e[1;32m\]"
[[ -z "$C_RED" ]]    && readonly C_RED="\[\e[1;31m\]"
[[ -z "$C_BLUE" ]]   && readonly C_BLUE="\[\e[1;34m\]"
[[ -z "$C_YELLOW" ]] && readonly C_YELLOW="\[\e[1;33m\]"
[[ -z "$C_PURPLE" ]] && readonly C_PURPLE="\[\e[1;35m\]"
[[ -z "$C_CYAN" ]]   && readonly C_CYAN="\[\e[1;36m\]"
[[ -z "$C_GRAY" ]]   && readonly C_GRAY="\[\e[0;37m\]"
[[ -z "$C_WHITE" ]]  && readonly C_WHITE="\[\e[1;37m\]"
#------------------------------- FIM-CONSTANTES -------------------------------<


#-------------------------------- UTILITÁRIOS --------------------------------->
# Atualiza a largura da tela dinamicamente (Signal Trap)
trap 'COLUMNS=$(tput cols)' SIGWINCH
COLUMNS=${COLUMNS:-$(tput cols 2>/dev/null || echo 80)}

# Retorna o tamanho real da string ignorando os escapes ANSI e marcadores do Bash \[\]
get_visible_length() {
    local string="$1"
    string=$(printf "%s" "$string" | sed -E 's/\\\[|\\\]//g; s/\x1B\[[0-9;]*[a-zA-Z]//g')
    printf "%s" "${#string}"
}

# Formata milissegundos para um formato humano legível (ms, s, m)
format_time() {
    local ms="$1"
    
    if (( ms < 1000 )); then
        printf "%sms" "${ms}"
        return
    fi
    
    local s=$(( ms / 1000 ))
    if (( s < 60 )); then
        printf "%s.%ss" "${s}" "$(( (ms % 1000) / 100 ))"
        return
    fi
    
    printf "%sm%ss" "$(( s / 60 ))" "$(( s % 60 ))"
}

# Obtém timestamp atual em milissegundos tratando ponto e vírgula de locale
get_time_ms() {
    if [[ -n "$EPOCHREALTIME" ]]; then
        # Normaliza a vírgula para ponto caso o sistema esteja em pt_BR
        local epoch_norm="${EPOCHREALTIME/,/.}"
        local sec="${epoch_norm%.*}"
        local usec="${epoch_norm#*.}"
        printf "%s%s" "$sec" "${usec:0:3}"
    else
        date +%s%3N
    fi
}
#------------------------------ FIM-UTILITÁRIOS -------------------------------<


#---------------------------- MÓDULOS DE CONTEXTO ----------------------------->
get_compact_path() {
    local current_path="$PWD"
    local home_path="${HOME%/}"
    
    [[ "$current_path" == "$home_path"* ]] && current_path="~${current_path#$home_path}"
    (( ${#current_path} > 50 )) && current_path="...${current_path: -50}"
    
    printf "%s" "$current_path"
}

get_git_block() {
    git rev-parse --is-inside-work-tree &>/dev/null || return
    
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
    
    local dirty=""
    git diff --quiet 2>/dev/null || dirty="*"
    
    printf "[ git:%s%s ]" "$branch" "$dirty"
}

get_docker_block() {
    if [[ -f /.dockerenv ]] || grep -q 'docker\|lxc' /proc/1/cgroup 2>/dev/null; then
        printf "[ container ]"
    fi
}

get_venv_block() {
    [[ -n "$VIRTUAL_ENV" ]] && printf "[ py:%s ]" "${VIRTUAL_ENV##*/}"
}

get_ssh_block() {
    [[ -n "$SSH_CONNECTION" ]] && printf "[ SSH ]"
}

get_jobs_block() {
    local active_jobs
    active_jobs=$(jobs -p | wc -l)
    (( active_jobs > 0 )) && printf "[ jobs:%s ]" "$active_jobs"
}

get_exit_block() {
    local exit_code="$1"
    (( exit_code != 0 )) && printf "[ exit:%s ]" "$exit_code"
}
#-------------------------- FIM-MÓDULOS DE CONTEXTO ---------------------------<


#-------------------------------- MOTOR DE TEMPO ------------------------------>
timer_start() {
    [[ "$BASH_COMMAND" == "build_prompt" ]] && return
    CMD_START=$(get_time_ms)
    CMD_RUNNING=1
}
trap 'timer_start' DEBUG

timer_stop() {
    if (( CMD_RUNNING == 1 )); then
        local now=$(get_time_ms)
        local diff=$(( now - CMD_START ))
        CMD_RUNNING=0
        
        if (( diff > 50 )); then
            # Guarda apenas o texto plano para não quebrar o cálculo das colunas
            TIMER_VAL=$(format_time "$diff")
            
            # Marca como comando longo (> 5s) para mudar a cor dinamicamente
            if (( diff > 5000 )); then
                TIMER_IS_LONG=1
            else
                TIMER_IS_LONG=0
            fi
        else
            TIMER_VAL=""
            TIMER_IS_LONG=0
        fi
    else
        TIMER_VAL=""
        TIMER_IS_LONG=0
    fi
}
#------------------------------ FIM-MOTOR DE TEMPO ----------------------------<


#------------------------------ MOTOR PRINCIPAL ------------------------------->
build_prompt() {
    # 1. Salva estado inicial
    local last_exit=$?
    timer_stop

    # 2. Configuração de cores dinâmicas do usuário
    local user_color="$C_GREEN"
    [[ $EUID -eq 0 ]] && user_color="$C_RED"

    # 3. Construção da Linha Superior (Informação de Sistema)
    local host_info="[ $USER@${HOSTNAME:-$(hostname)} ]"
    local path_info="[ $(get_compact_path) ]"

    local top_raw="$host_info $path_info"
    local top_color="${user_color}${host_info}${C_RESET} ${C_BLUE}${path_info}${C_RESET}"

    # Iteração sobre blocos de contexto (Abordagem Modular)
    local block_types=("get_ssh_block" "get_docker_block" "get_venv_block" "get_git_block")
    local block_res
    
    for block in "${block_types[@]}"; do
        block_res=$($block)
        if [[ -n "$block_res" ]]; then
            top_raw="$top_raw $block_res"
            
            case "$block" in
                get_docker_block) top_color="$top_color ${C_WHITE}${block_res}${C_RESET}"  ;;
                get_venv_block)   top_color="$top_color ${C_YELLOW}${block_res}${C_RESET}" ;;
                get_git_block)    top_color="$top_color ${C_CYAN}${block_res}${C_RESET}"   ;;
                get_ssh_block)    top_color="$top_color ${C_PURPLE}${block_res}${C_RESET}" ;;
            esac
        fi
    done

    # 4. Construção da Linha Inferior (Status e Relógio)
    local jobs_info=$(get_jobs_block)
    local exit_info=$(get_exit_block "$last_exit")
    local clock_info="[ $(date +%H:%M:%S) ]"

    # Define a cor do timer: Cinza para <5s, Vermelho para >=5s
    # Nota: Caso queira o timer SEMPRE vermelho, altere "$C_GRAY" para "$C_RED" abaixo.
    local timer_color="$C_GRAY"
    (( TIMER_IS_LONG == 1 )) && timer_color="$C_RED"

    # Texto PURO para cálculo perfeito do espaçamento
    local timer_raw="${TIMER_VAL:+[ $TIMER_VAL ] }"
    local bottom_l_raw="$jobs_info"
    local bottom_r_raw="${timer_raw}${exit_info:+$exit_info }$clock_info"

    # Texto COLORIDO para renderização visual
    local bottom_l_col="${C_PURPLE}${jobs_info}${C_RESET}"
    local bottom_r_col="${TIMER_VAL:+${timer_color}[ $TIMER_VAL ]${C_RESET} }${exit_info:+${C_RED}${exit_info}${C_RESET} }${C_YELLOW}${clock_info}${C_RESET}"

    # 5. Cálculo de Espaçamento Dinâmico (Alinhamento à direita)
    local left_len=$(get_visible_length "$bottom_l_raw")
    local right_len=$(get_visible_length "$bottom_r_raw")
    
    local space=$(( COLUMNS - left_len - right_len ))
    (( space < 1 )) && space=1
    
    local padding=$(printf "%${space}s")

    # 6. Renderização Final do PS1
    PS1="${top_color}\n${bottom_l_col}${padding}${bottom_r_col}\n$ "

    # 7. Atualização do Título do Emulador de Terminal
    printf "\033]0;%s@%s: %s\007" "$USER" "${HOSTNAME:-$(hostname)}" "${PWD}"
}

# Define o gatilho para a construção do prompt
PROMPT_COMMAND=build_prompt
#---------------------------- FIM-MOTOR PRINCIPAL -----------------------------<

# Habilitando Bash Completion
if ! shopt -oq posix; then
    [[ -r /usr/share/bash-completion/bash_completion ]] &&
        . /usr/share/bash-completion/bash_completion
fi

# Habilitando extras do Doom Emacs / Emacs
export PATH="$HOME/.config/emacs/bin:$PATH"

# Ativar modo Dark Theme no GTK4 execute o comando abaixo
# gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

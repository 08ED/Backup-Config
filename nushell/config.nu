def select-shell [] {
    clear
    let term_width = (term size).columns
    let padding = (($term_width - 44) / 2 | math floor | into int)
    let pad = (" " | fill --width $padding)

    # Tampilan Menu
    print $"\n($pad)(ansi yellow_bold)╭──────────────────────────────────────────╮"
    print $"($pad)│        RIO TERMINAL SHELL SELECTOR       │"
    print $"($pad)╰──────────────────────────────────────────╯(ansi reset)"
    print $"($pad)  1. Nushell"
    print $"($pad)  2. PowerShell"
    print $"($pad)  3. Command Prompt"
    print ""

    let prompt_text = $pad + "Pilih nomor [1/2/3]: "
    let choice = (input $prompt_text)

    match $choice {
        "2" => {
            clear 
            ^pwsh --nologo
        }
        "3" => {
            clear 
            ^cmd /k
        }
        _ => {
            clear # Membersihkan menu selector agar welcome Nushell rapi di atas
        }
    }
}

# Panggil fungsi launcher
select-shell

# config.nu
#
# Installed by:
# version = "0.108.0"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# Nushell sets "sensible defaults" for most configuration settings, 
# so your `config.nu` only needs to override these defaults if desired.
#
# You can open this file in your default editor using:
#     config nu
#
# You can also pretty-print and page through the documentation for configuration
# options using:
#     config nu --doc | nu-highlight | less -R

$env.config.shell_integration.osc133 = false
$env.config.table.mode = "rounded"
$env.config.show_banner = true

# --- Custom Welcome Message ---
def --env welcome [] {
    let host = (sys host)
    let hostname = $host.hostname
    let os = $host.name
    let kernel = $host.kernel_version
    let uptime = $host.uptime
    
    let mem_free = (((sys mem | get free | into int) / (1mb | into int)) | math round --precision 2 | into string | append " MB" | str join)
	
    print $"\n(ansi yellow)╭──────────────────────────────────────────╮(ansi reset)"
    print $"  (ansi red_bold)Hello, 083D!(ansi reset) @ (ansi cyan_bold)($hostname)(ansi reset)"
    print $"  (ansi dark_gray)──────────────────────────────────────────(ansi reset)"
    print $"  (ansi blue_bold)󰣚 OS:      (ansi reset)($os)"
    print $"  (ansi magenta_bold)󰒄 Kernel:  (ansi reset)($kernel)"
    print $"  (ansi yellow_bold)󱎫 Uptime:  (ansi reset)($uptime)"
    print $"  (ansi green_bold)󰚀 Sisa RAM: (ansi reset)($mem_free)"
    print $"(ansi yellow)╰──────────────────────────────────────────╯(ansi reset)"
    print ""
}

# Jalankan fungsinya
welcome

# Menghubungkan Zoxide ke Nushell tanpa mengganggu shell lain
zoxide init nushell | save -f ~/.zoxide.nu
source ~/.zoxide.nu

# Alias standar ala Linux
def --env ll [] {
    ls | grid
}
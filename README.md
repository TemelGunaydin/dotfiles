# Kişisel Mac kurulumu

[kunchenguid/dotfiles](https://github.com/kunchenguid/dotfiles/tree/9a4a6387d0dd6f4bf9b8a5a732b406916bbbf95d)
yapısından uyarlanmıştır. Kendi zsh alias'ların ve Neovim config'in korunur;
WezTerm görünümü kaynak repodan alınır. Starship prompt'u ve kaynak reponun
yardımcı config'leri eklenir.

## Dosyaların görevleri

| Dosya | Sorumluluğu |
| --- | --- |
| `bootstrap.sh` | İlk kurulum: Nix, kullanıcı adı, Oh My Zsh ve eklentiler, ilk rebuild |
| `rebuild.sh` | Repo bağlantısını kurup yapılandırmayı uygulamak |
| `configuration.nix` | Homebrew/npm paketleri ve macOS tercihleri |
| `home.nix` | Kullanıcı config dosyalarının hedef konumlarını tanımlamak |
| `home/` | Düzenlediğin asıl config dosyaları |

```text
home/
  .config/
    nvim/                 kişisel Neovim ayarların ve lazy-lock.json
    wezterm/              kaynak reponun Rosé Pine Moon / Hack Nerd Font ayarları
    herdr/config.toml     mevcut tercihlerin ve kaynak reponun kısayolları
    starship.toml         prompt ayarları
    zellij/               saklanıyor; kurulumu ve bağlantısı kapalı
  .claude/settings.json   Claude renk ve bağlam kullanım satırı
  .pi/agent/
    themes/               rose-pine-moon teması
    extensions/           calm, terminal başlığı ve mevcut kişisel eklentilerin
    settings.json         kişisel Pi tercihlerin ve eklenti listesi
    models.json           kişisel LM Studio sağlayıcın ve model tanımları
  .zshrc                  alias'ların, eklentilerin ve Starship başlangıcı
  .zprofile
  .zshenv
  AGENTS.md               Claude, Codex ve OpenCode için ortak talimatlar
  CLAUDE.md               ortak talimat dosyasına yönlendirme
```

Config klasörünün tam yolu `home/.config/` şeklindedir. Başındaki nokta nedeniyle
Finder'da gizlidir; `Cmd+Shift+.` ile gizli dosyaları gösterebilirsin.

WezTerm, kaynak repodaki gibi başlık çubuğu olmadan açılır; tek sekmede sekme
çubuğu gizlenir. Rosé Pine Moon teması, 15 punto Hack Nerd Font, şeffaflık,
macOS bulanıklığı ve odakta olmayan pencereleri soluklaştırma ayarları kullanılır.
Hack Nerd Font, `configuration.nix` üzerinden Homebrew ile kurulur.

`home/AGENTS.md`, kaynak reponun ortak talimatlarına mevcut CodeGraph/RTK
kurallarını da ekler. Kendi agent tercihlerini burada düzenleyebilirsin.

## Yeni Mac'te kurulum

Önce bu repodaki yeni dosyaları mevcut Mac'inde commit edip kendi uzak repona
gönder. Yeni Mac'te Git erişimiyle repoyu klonlayıp klasörüne gir ve çalıştır:

```sh
./bootstrap.sh
```

Script Nix eksikse Determinate Nix'i kurar, kullanıcı adını kontrol eder,
Oh My Zsh ile üç zsh eklentisini eksikse indirir ve ilk nix-darwin switch'i
başlatır. Mevcut Oh My Zsh klasörlerine dokunmaz. `darwin-rebuild` henüz yoksa
Nix üzerinden ilk kurulum aracını çağırır. Script'i normal kullanıcı olarak
çalıştır; gerektiğinde kendisi `sudo` çağırır.

Varsayılan hedef Apple Silicon'dur. Intel Mac'te `configuration.nix` içindeki
`nixpkgs.hostPlatform` değerini `x86_64-darwin` yap. Farklı kullanıcı adıyla
kurulumda bootstrap, `flake.nix` içindeki kullanıcı adını güncellemeyi sorar.
Aktif zsh yolları `$HOME` kullanır.

`configuration.nix` içindeki `system.defaults` bölümü de uygulanır: koyu tema,
Dock/menü çubuğunu otomatik gizleme ve masaüstü simgelerini gizleme gibi
tercihleri çalıştırmadan önce gözden geçir.

## Sonraki değişiklikler

Paket veya Nix seçeneklerini değiştirdikten sonra:

```sh
./rebuild.sh
```

Rebuild, Homebrew listesindeki eksik araçları kurar ve `home.nix` bağlantılarını
uygular. Codex ve Claude Code mevcut kurulumdaki gibi npm ile, OpenCode
`anomalyco/tap` üzerinden tanımlıdır. CodeGraph ve RTK da ortak talimatlar ve
mevcut Pi eklentisi için listededir. `home.packages` boş olduğu için aynı
araçların ayrıca Nix kopyaları kurulmaz.

Config dosyaları `~/.dotfiles` üzerinden repoya bağlanır. Örneğin `~/.zshrc`,
`home/.zshrc` dosyasını kullanır. Alias değişiklikleri için dosyayı düzenleyip
yeni terminal açmak yeterlidir. Neovim ve WezTerm dosyalarını da repoda düzenle.
Hem `~/.wezterm.lua` hem `~/.config/wezterm` aynı config kaynağına bağlıdır.
Bu bağlantılardaki dosyaları düzenlemek için yeniden rebuild gerekmez.
WezTerm değişiklikleri otomatik yükler; gerekirse `Ctrl+Shift+R` ile config'i
yeniden yükle veya yeni pencere aç.
`programs.zsh.enable = false`, Home Manager'ın yeni `.zshrc` üretmesini kapatır;
zsh'ın çalışmasını etkilemez.

Home Manager, çakışan mevcut dosyaları `.before-home-manager` uzantısıyla yedekler.
Bu adda eski yedek varsa üzerine yazmaz. Homebrew `cleanup = "none"` listede
olmayan uygulamaları korur; rebuild sırasında otomatik yükseltme kapalıdır.
Yeni dosyaların Git'e alınması, başka Mac'e de taşınabilmeleri için gereklidir:

```sh
git add .gitignore LICENSE README.md bootstrap.sh rebuild.sh configuration.nix flake.nix flake.lock home.nix home tests
```

## Pi ve yerel veriler

Kaynak repodaki gibi Pi'nin kendisi ayrı kurulur; mevcut bağımsız Pi kurulumun
korunur. Pi kullanacaksan yeni Mac'te [resmi kurulum adımlarını](https://pi.dev)
uygula. Tema, Calm ve terminal başlığı eklentileri bu repoda hazırdır. Kişisel
Pi modelin, düşünme seviyesi, `dark` teması, RTK/model-status eklentileri ve mevcut
paket listen korundu; kaynak reponun iki sabit sürümlü Pi paketi listeye eklendi.
`rose-pine-moon` kullanmak için `home/.pi/agent/settings.json` içindeki `theme`
değerini değiştir. Calm, `/calm` ile açılıp kapanır; durumu yerel kalır.

`models.json` içindeki `lm-studio` değeri yerel sunucunun anahtarsız kullanımına
ait bir yer tutucudur. Sunucunun ağ adresi değişirse bu dosyayı güncelle.
Gerçek API anahtarları, oturumlar, Pi MCP bağlantıları ve uygulama verileri repoya
alınmaz. Codex'in `config.toml` dosyası ve OpenCode'un kişisel MCP/plugin
config'leri de ayrı yönetilmeye devam eder. Bu repo tam disk yedeği değildir.

Zellij klasörü saklanır, fakat seçimin doğrultusunda paket ve Home Manager
bağlantısı kapalıdır. `ai-cli` alias'ını yeni Mac'te kullanmak istersen Zellij'i
ve config bağlantısını tekrar etkinleştir; layout'taki Cursor/Bun araçları da
ayrıca gereklidir.

## Uygulamadan doğrulama

```sh
python3 -B -m unittest discover -s tests -p 'test_*.py'
bash -n bootstrap.sh rebuild.sh
nix eval --raw .#darwinConfigurations.mac.system.drvPath
```

Bootstrap testleri geçici ev dizinleri ve sahte `sudo`/kurulum komutları kullanır;
gerçek sisteme paket kurmaz. Kaynak repodan alınan Pi Calm testleri:

```sh
bash tests/pi-calm.test.sh
```

Pi npm'in global dizininden farklı bir yere kurulmuşsa test için
`PI_CALM_TEST_PACKAGE_DIR` değişkenini kurulu `@earendil-works/pi-coding-agent`
paket dizinine ayarla. TypeScript/TUI kontrolleri ilgili yerel araçları gerektirir.

Homebrew paketleri ve Oh My Zsh Git klonları sürüm sabitlemez; Nix bağımlılıkları
`flake.lock`, Neovim eklentileri `lazy-lock.json` ile tanımlıdır. Pi paketlerinin
sürümleri `settings.json` içindeki her girdiye bağlıdır.

-- Satır numaralarını göster
vim.opt.termguicolors = true

vim.opt.nu = true

-- Göreli satır numaralarını göster (hareketler için pratik)
vim.opt.relativenumber = true

-- Bir tab karakteri görselde kaç boşluk genişliğinde olsun
vim.opt.tabstop = 4

-- Tab tuşuna bastığında kaç boşluk eklensin
vim.opt.softtabstop = 4

-- Otomatik girintilemede kaç boşluk kullanılsın
vim.opt.shiftwidth = 4

-- Tab karakterini boşluğa çevir
vim.opt.expandtab = true

-- Akıllı girintileme (kod bloklarında otomatik indent)
vim.opt.smartindent = true

-- Satırları katlama yerine tek satırda gösterme

-- Swap dosyalarını kapat
vim.opt.swapfile = false

-- Yedek dosyalarını kapat
vim.opt.backup = false

-- Geri alma (undo) geçmişinin tutulacağı klasör
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
-- Kalıcı undo dosyası kullan

vim.opt.undofile = true

-- Arama sonuçlarını vurgula
vim.opt.hlsearch = true

-- Yazdıkça arama yap (inkremental arama)
vim.opt.incsearch = true

-- Ekranın üst/alt kenarlarında minimum satır boşluğu
-- Keep this at 0 so commands like `zt` can truly place the cursor line at the top.
-- Increase temporarily if you prefer a context margin while moving around.
vim.opt.scrolloff = 0

-- İşaret sütununu (signcolumn) her zaman göster
vim.opt.signcolumn = "yes"

-- Dosya adı karakterlerine "@-@" ekle (örn. e-posta benzeri adlar)
vim.opt.isfname:append("@-@")

-- Daha düşük updatetime ile daha hızlı CursorHold vb.
vim.opt.updatetime = 50

-- Fareyi tüm modlarda etkinleştir
vim.opt.mouse = "a"

-- Dikey renk sütunu kapalı
vim.opt.colorcolumn = ""

-- Uzun satırları görselde sar (wrap) açık
vim.opt.wrap = true

-- İmlecin bulunduğu satırı vurgula
vim.opt.cursorline = true

-- Markdown/LaTeX gibi dosyalarda gizleme düzeyi
vim.opt.conceallevel = 2

-- Sistem panosunu kullan (pbcopy/pbpaste ile entegrasyon)
vim.opt.clipboard = "unnamedplus"

-- Ensure Homebrew tools are in PATH for Neovim
-- PATH değişkenine Homebrew ve /usr/local ekle
vim.env.PATH = vim.env.PATH .. ":/opt/homebrew/bin:/usr/local/bin"

vim.o.foldcolumn = "1" -- '0' is not bad
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true

-- lsp.lua dosyasindan alindi.
-- Reserve a space in the gutter
vim.opt.signcolumn = "yes"

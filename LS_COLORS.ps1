# http://www.bigsoft.co.uk/blog/2008/04/11/configuring-ls_colors
# https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797#256-colors
# https://4sysops.com/archives/using-powershell-with-psstyle/
# pwshのprofile で読み込め →  . path\to\LC_CORLS.ps1 

$PSStyle.FileInfo.Directory = "`e[38;5;30m" # ディレクトリは緑
$PSStyle.FileInfo.Extension[".txt"] = "`e[38;5;253m"
$PSStyle.FileInfo.Extension[".log"] = "`e[38;5;190m"
$PSStyle.FileInfo.Extension[".adoc"] = "`e[38;5;184m"
$PSStyle.FileInfo.Extension[".asciidoc"] = "`e[38;5;184m"
$PSStyle.FileInfo.Extension[".etx"] = "`e[38;5;184m"
$PSStyle.FileInfo.Extension[".info"] = "`e[38;5;184m"
$PSStyle.FileInfo.Extension[".markdown"] = "`e[38;5;184m"
$PSStyle.FileInfo.Extension[".md"] = "`e[38;5;184m"
$PSStyle.FileInfo.Extension[".mkd"] = "`e[38;5;184m"
$PSStyle.FileInfo.Extension[".nfo"] = "`e[38;5;184m"
$PSStyle.FileInfo.Extension[".org"] = "`e[38;5;184m"
$PSStyle.FileInfo.Extension[".pod"] = "`e[38;5;184m"
$PSStyle.FileInfo.Extension[".rst"] = "`e[38;5;184m"
$PSStyle.FileInfo.Extension[".tex"] = "`e[38;5;184m"
$PSStyle.FileInfo.Extension[".textile"] = "`e[38;5;184m"
$PSStyle.FileInfo.Extension[".bib"] = "`e[38;5;178m"
$PSStyle.FileInfo.Extension[".json"] = "`e[38;5;178m"
$PSStyle.FileInfo.Extension[".jsonl"] = "`e[38;5;178m"
$PSStyle.FileInfo.Extension[".jsonnet"] = "`e[38;5;178m"
$PSStyle.FileInfo.Extension[".libsonnet"] = "`e[38;5;142m"
$PSStyle.FileInfo.Extension[".ndjson"] = "`e[38;5;178m"
$PSStyle.FileInfo.Extension[".msg"] = "`e[38;5;178m"
$PSStyle.FileInfo.Extension[".pgn"] = "`e[38;5;178m"
$PSStyle.FileInfo.Extension[".rss"] = "`e[38;5;178m"
$PSStyle.FileInfo.Extension[".xml"] = "`e[38;5;178m"
$PSStyle.FileInfo.Extension[".fxml"] = "`e[38;5;178m"
$PSStyle.FileInfo.Extension[".toml"] = "`e[38;5;178m"
$PSStyle.FileInfo.Extension[".yaml"] = "`e[38;5;178m"
$PSStyle.FileInfo.Extension[".yml"] = "`e[38;5;178m"
$PSStyle.FileInfo.Extension[".RData"] = "`e[38;5;178m"
$PSStyle.FileInfo.Extension[".rdata"] = "`e[38;5;178m"
$PSStyle.FileInfo.Extension[".xsd"] = "`e[38;5;178m"
$PSStyle.FileInfo.Extension[".dtd"] = "`e[38;5;178m"
$PSStyle.FileInfo.Extension[".sgml"] = "`e[38;5;178m"
$PSStyle.FileInfo.Extension[".rng"] = "`e[38;5;178m"
$PSStyle.FileInfo.Extension[".rnc"] = "`e[38;5;178m"
$PSStyle.FileInfo.Extension[".accdb"] = "`e[38;5;60m"
$PSStyle.FileInfo.Extension[".accde"] = "`e[38;5;60m"
$PSStyle.FileInfo.Extension[".accdr"] = "`e[38;5;60m"
$PSStyle.FileInfo.Extension[".accdt"] = "`e[38;5;60m"
$PSStyle.FileInfo.Extension[".db"] = "`e[38;5;60m"
$PSStyle.FileInfo.Extension[".fmp12"] = "`e[38;5;60m"
$PSStyle.FileInfo.Extension[".fp7"] = "`e[38;5;60m"
$PSStyle.FileInfo.Extension[".localstorage"] = "`e[38;5;60m"
$PSStyle.FileInfo.Extension[".mdb"] = "`e[38;5;60m"
$PSStyle.FileInfo.Extension[".mde"] = "`e[38;5;60m"
$PSStyle.FileInfo.Extension[".sqlite"] = "`e[38;5;60m"
$PSStyle.FileInfo.Extension[".typelib"] = "`e[38;5;60m"
$PSStyle.FileInfo.Extension[".nc"] = "`e[38;5;60m"
$PSStyle.FileInfo.Extension[".cbr"] = "`e[38;5;141m"
$PSStyle.FileInfo.Extension[".cbz"] = "`e[38;5;141m"
$PSStyle.FileInfo.Extension[".chm"] = "`e[38;5;141m"
$PSStyle.FileInfo.Extension[".djvu"] = "`e[38;5;141m"
$PSStyle.FileInfo.Extension[".pdf"] = "`e[38;5;141m"
$PSStyle.FileInfo.Extension[".PDF"] = "`e[38;5;141m"
$PSStyle.FileInfo.Extension[".mobi"] = "`e[38;5;141m"
$PSStyle.FileInfo.Extension[".epub"] = "`e[38;5;141m"
$PSStyle.FileInfo.Extension[".docm"] = "`e[38;5;111;4m"
$PSStyle.FileInfo.Extension[".doc"] = "`e[38;5;111m"
$PSStyle.FileInfo.Extension[".docx"] = "`e[38;5;111m"
$PSStyle.FileInfo.Extension[".odb"] = "`e[38;5;111m"
$PSStyle.FileInfo.Extension[".odt"] = "`e[38;5;111m"
$PSStyle.FileInfo.Extension[".rtf"] = "`e[38;5;111m"
$PSStyle.FileInfo.Extension[".pages"] = "`e[38;5;111m"
$PSStyle.FileInfo.Extension[".odp"] = "`e[38;5;166m"
$PSStyle.FileInfo.Extension[".pps"] = "`e[38;5;166m"
$PSStyle.FileInfo.Extension[".ppt"] = "`e[38;5;166m"
$PSStyle.FileInfo.Extension[".pptx"] = "`e[38;5;166m"
$PSStyle.FileInfo.Extension[".ppts"] = "`e[38;5;166m"
$PSStyle.FileInfo.Extension[".pptxm"] = "`e[38;5;166;4m"
$PSStyle.FileInfo.Extension[".pptsm"] = "`e[38;5;166;4m"
$PSStyle.FileInfo.Extension[".csv"] = "`e[38;5;78m"
$PSStyle.FileInfo.Extension[".tsv"] = "`e[38;5;78m"
$PSStyle.FileInfo.Extension[".numbers"] = "`e[38;5;112m"
$PSStyle.FileInfo.Extension[".ods"] = "`e[38;5;112m"
$PSStyle.FileInfo.Extension[".xla"] = "`e[38;5;76m"
$PSStyle.FileInfo.Extension[".xls"] = "`e[38;5;112m"
$PSStyle.FileInfo.Extension[".xlsx"] = "`e[38;5;112m"
$PSStyle.FileInfo.Extension[".xlsxm"] = "`e[38;5;112;4m"
$PSStyle.FileInfo.Extension[".xltm"] = "`e[38;5;73;4m"
$PSStyle.FileInfo.Extension[".xltx"] = "`e[38;5;73m"
$PSStyle.FileInfo.Extension[".key"] = "`e[38;5;166m"
$PSStyle.FileInfo.Extension[".ini"] = "`e[1m"
$PSStyle.FileInfo.Extension[".plist"] = "`e[1m"
$PSStyle.FileInfo.Extension[".profile"] = "`e[1m"
$PSStyle.FileInfo.Extension[".bash_profile"] = "`e[1m"
$PSStyle.FileInfo.Extension[".bash_login"] = "`e[1m"
$PSStyle.FileInfo.Extension[".bash_logout"] = "`e[1m"
$PSStyle.FileInfo.Extension[".zshenv"] = "`e[1m"
$PSStyle.FileInfo.Extension[".zprofile"] = "`e[1m"
$PSStyle.FileInfo.Extension[".zlogin"] = "`e[1m"
$PSStyle.FileInfo.Extension[".zlogout"] = "`e[1m"
$PSStyle.FileInfo.Extension[".viminfo"] = "`e[1m"
$PSStyle.FileInfo.Extension[".pcf"] = "`e[1m"
$PSStyle.FileInfo.Extension[".psf"] = "`e[1m"
$PSStyle.FileInfo.Extension[".hidden-color-scheme"] = "`e[1m"
$PSStyle.FileInfo.Extension[".hidden-tmTheme"] = "`e[1m"
$PSStyle.FileInfo.Extension[".last-run"] = "`e[1m"
$PSStyle.FileInfo.Extension[".merged-ca-bundle"] = "`e[1m"
$PSStyle.FileInfo.Extension[".sublime-build"] = "`e[1m"
$PSStyle.FileInfo.Extension[".sublime-commands"] = "`e[1m"
$PSStyle.FileInfo.Extension[".sublime-keymap"] = "`e[1m"
$PSStyle.FileInfo.Extension[".sublime-settings"] = "`e[1m"
$PSStyle.FileInfo.Extension[".sublime-snippet"] = "`e[1m"
$PSStyle.FileInfo.Extension[".sublime-project"] = "`e[1m"
$PSStyle.FileInfo.Extension[".sublime-workspace"] = "`e[1m"
$PSStyle.FileInfo.Extension[".tmTheme"] = "`e[1m"
$PSStyle.FileInfo.Extension[".user-ca-bundle"] = "`e[1m"
$PSStyle.FileInfo.Extension[".rstheme"] = "`e[1m"
$PSStyle.FileInfo.Extension[".epf"] = "`e[1m"
$PSStyle.FileInfo.Extension[".git"] = "`e[38;5;197m"
$PSStyle.FileInfo.Extension[".gitignore"] = "`e[38;5;240m"
$PSStyle.FileInfo.Extension[".gitattributes"] = "`e[38;5;240m"
$PSStyle.FileInfo.Extension[".gitmodules"] = "`e[38;5;240m"
$PSStyle.FileInfo.Extension[".awk"] = "`e[38;5;172m"
$PSStyle.FileInfo.Extension[".bash"] = "`e[38;5;172m"
$PSStyle.FileInfo.Extension[".bat"] = "`e[38;5;172m"
$PSStyle.FileInfo.Extension[".BAT"] = "`e[38;5;172m"
$PSStyle.FileInfo.Extension[".sed"] = "`e[38;5;172m"
$PSStyle.FileInfo.Extension[".sh"] = "`e[38;5;172m"
$PSStyle.FileInfo.Extension[".zsh"] = "`e[38;5;172m"
$PSStyle.FileInfo.Extension[".vim"] = "`e[38;5;172m"
$PSStyle.FileInfo.Extension[".kak"] = "`e[38;5;172m"
$PSStyle.FileInfo.Extension[".ahk"] = "`e[38;5;41m"
$PSStyle.FileInfo.Extension[".py"] = "`e[38;5;41m"
$PSStyle.FileInfo.Extension[".ipynb"] = "`e[38;5;41m"
$PSStyle.FileInfo.Extension[".xsh"] = "`e[38;5;41m"
$PSStyle.FileInfo.Extension[".rb"] = "`e[38;5;41m"
$PSStyle.FileInfo.Extension[".gemspec"] = "`e[38;5;41m"
$PSStyle.FileInfo.Extension[".pl"] = "`e[38;5;208m"
$PSStyle.FileInfo.Extension[".PL"] = "`e[38;5;160m"
$PSStyle.FileInfo.Extension[".pm"] = "`e[38;5;203m"
$PSStyle.FileInfo.Extension[".t"] = "`e[38;5;114m"
$PSStyle.FileInfo.Extension[".msql"] = "`e[38;5;222m"
$PSStyle.FileInfo.Extension[".mysql"] = "`e[38;5;222m"
$PSStyle.FileInfo.Extension[".pgsql"] = "`e[38;5;222m"
$PSStyle.FileInfo.Extension[".sql"] = "`e[38;5;222m"
$PSStyle.FileInfo.Extension[".tcl"] = "`e[38;5;64;1m"
$PSStyle.FileInfo.Extension[".r"] = "`e[38;5;49m"
$PSStyle.FileInfo.Extension[".R"] = "`e[38;5;49m"
$PSStyle.FileInfo.Extension[".gs"] = "`e[38;5;81m"
$PSStyle.FileInfo.Extension[".clj"] = "`e[38;5;41m"
$PSStyle.FileInfo.Extension[".cljs"] = "`e[38;5;41m"
$PSStyle.FileInfo.Extension[".cljc"] = "`e[38;5;41m"
$PSStyle.FileInfo.Extension[".cljw"] = "`e[38;5;41m"
$PSStyle.FileInfo.Extension[".scala"] = "`e[38;5;41m"
$PSStyle.FileInfo.Extension[".sc"] = "`e[38;5;41m"
$PSStyle.FileInfo.Extension[".dart"] = "`e[38;5;51m"
$PSStyle.FileInfo.Extension[".asm"] = "`e[38;5;81m"
$PSStyle.FileInfo.Extension[".cl"] = "`e[38;5;81m"
$PSStyle.FileInfo.Extension[".lisp"] = "`e[38;5;81m"
$PSStyle.FileInfo.Extension[".rkt"] = "`e[38;5;81m"
$PSStyle.FileInfo.Extension[".el"] = "`e[38;5;81m"
$PSStyle.FileInfo.Extension[".elc"] = "`e[38;5;241m"
$PSStyle.FileInfo.Extension[".eln"] = "`e[38;5;241m"
$PSStyle.FileInfo.Extension[".lua"] = "`e[38;5;81m"
$PSStyle.FileInfo.Extension[".moon"] = "`e[38;5;81m"
$PSStyle.FileInfo.Extension[".c"] = "`e[38;5;81m"
$PSStyle.FileInfo.Extension[".C"] = "`e[38;5;81m"
$PSStyle.FileInfo.Extension[".h"] = "`e[38;5;110m"
$PSStyle.FileInfo.Extension[".H"] = "`e[38;5;110m"
$PSStyle.FileInfo.Extension[".tcc"] = "`e[38;5;110m"
$PSStyle.FileInfo.Extension[".c++"] = "`e[38;5;81m"
$PSStyle.FileInfo.Extension[".h++"] = "`e[38;5;110m"
$PSStyle.FileInfo.Extension[".hpp"] = "`e[38;5;110m"
$PSStyle.FileInfo.Extension[".hxx"] = "`e[38;5;110m"
$PSStyle.FileInfo.Extension[".ii"] = "`e[38;5;110m"
$PSStyle.FileInfo.Extension[".M"] = "`e[38;5;110m"
$PSStyle.FileInfo.Extension[".m"] = "`e[38;5;110m"
$PSStyle.FileInfo.Extension[".cc"] = "`e[38;5;81m"
$PSStyle.FileInfo.Extension[".cs"] = "`e[38;5;81m"
$PSStyle.FileInfo.Extension[".cp"] = "`e[38;5;81m"
$PSStyle.FileInfo.Extension[".cpp"] = "`e[38;5;81m"
$PSStyle.FileInfo.Extension[".cxx"] = "`e[38;5;81m"
$PSStyle.FileInfo.Extension[".cr"] = "`e[38;5;81m"
$PSStyle.FileInfo.Extension[".go"] = "`e[38;5;81m"
$PSStyle.FileInfo.Extension[".f"] = "`e[38;5;81m"
$PSStyle.FileInfo.Extension[".F"] = "`e[38;5;81m"
$PSStyle.FileInfo.Extension[".for"] = "`e[38;5;81m"
$PSStyle.FileInfo.Extension[".ftn"] = "`e[38;5;81m"
$PSStyle.FileInfo.Extension[".f90"] = "`e[38;5;81m"
$PSStyle.FileInfo.Extension[".F90"] = "`e[38;5;81m"
$PSStyle.FileInfo.Extension[".f95"] = "`e[38;5;81m"
$PSStyle.FileInfo.Extension[".F95"] = "`e[38;5;81m"
$PSStyle.FileInfo.Extension[".f03"] = "`e[38;5;81m"
$PSStyle.FileInfo.Extension[".F03"] = "`e[38;5;81m"
$PSStyle.FileInfo.Extension[".f08"] = "`e[38;5;81m"
$PSStyle.FileInfo.Extension[".F08"] = "`e[38;5;81m"
$PSStyle.FileInfo.Extension[".nim"] = "`e[38;5;81m"
$PSStyle.FileInfo.Extension[".nimble"] = "`e[38;5;81m"
$PSStyle.FileInfo.Extension[".s"] = "`e[38;5;110m"
$PSStyle.FileInfo.Extension[".S"] = "`e[38;5;110m"
$PSStyle.FileInfo.Extension[".rs"] = "`e[38;5;81m"
$PSStyle.FileInfo.Extension[".scpt"] = "`e[38;5;219m"
$PSStyle.FileInfo.Extension[".swift"] = "`e[38;5;219m"
$PSStyle.FileInfo.Extension[".sx"] = "`e[38;5;81m"
$PSStyle.FileInfo.Extension[".vala"] = "`e[38;5;81m"
$PSStyle.FileInfo.Extension[".vapi"] = "`e[38;5;81m"
$PSStyle.FileInfo.Extension[".hi"] = "`e[38;5;110m"
$PSStyle.FileInfo.Extension[".hs"] = "`e[38;5;81m"
$PSStyle.FileInfo.Extension[".lhs"] = "`e[38;5;81m"
$PSStyle.FileInfo.Extension[".agda"] = "`e[38;5;81m"
$PSStyle.FileInfo.Extension[".lagda"] = "`e[38;5;81m"
$PSStyle.FileInfo.Extension[".lagda.tex"] = "`e[38;5;81m"
$PSStyle.FileInfo.Extension[".lagda.rst"] = "`e[38;5;81m"
$PSStyle.FileInfo.Extension[".lagda.md"] = "`e[38;5;81m"
$PSStyle.FileInfo.Extension[".agdai"] = "`e[38;5;110m"
$PSStyle.FileInfo.Extension[".zig"] = "`e[38;5;81m"
$PSStyle.FileInfo.Extension[".v"] = "`e[38;5;81m"
$PSStyle.FileInfo.Extension[".pyc"] = "`e[38;5;240m"
$PSStyle.FileInfo.Extension[".tf"] = "`e[38;5;168m"
$PSStyle.FileInfo.Extension[".tfstate"] = "`e[38;5;168m"
$PSStyle.FileInfo.Extension[".tfvars"] = "`e[38;5;168m"
$PSStyle.FileInfo.Extension[".css"] = "`e[38;5;125;1m"
$PSStyle.FileInfo.Extension[".less"] = "`e[38;5;125;1m"
$PSStyle.FileInfo.Extension[".sass"] = "`e[38;5;125;1m"
$PSStyle.FileInfo.Extension[".scss"] = "`e[38;5;125;1m"
$PSStyle.FileInfo.Extension[".htm"] = "`e[38;5;125;1m"
$PSStyle.FileInfo.Extension[".html"] = "`e[38;5;125;1m"
$PSStyle.FileInfo.Extension[".jhtm"] = "`e[38;5;125;1m"
$PSStyle.FileInfo.Extension[".mht"] = "`e[38;5;125;1m"
$PSStyle.FileInfo.Extension[".eml"] = "`e[38;5;125;1m"
$PSStyle.FileInfo.Extension[".mustache"] = "`e[38;5;125;1m"
$PSStyle.FileInfo.Extension[".coffee"] = "`e[38;5;074;1m"
$PSStyle.FileInfo.Extension[".java"] = "`e[38;5;074;1m"
$PSStyle.FileInfo.Extension[".js"] = "`e[38;5;074;1m"
$PSStyle.FileInfo.Extension[".mjs"] = "`e[38;5;074;1m"
$PSStyle.FileInfo.Extension[".jsm"] = "`e[38;5;074;1m"
$PSStyle.FileInfo.Extension[".jsp"] = "`e[38;5;074;1m"
$PSStyle.FileInfo.Extension[".php"] = "`e[38;5;81m"
$PSStyle.FileInfo.Extension[".ctp"] = "`e[38;5;81m"
$PSStyle.FileInfo.Extension[".twig"] = "`e[38;5;81m"
$PSStyle.FileInfo.Extension[".vb"] = "`e[38;5;81m"
$PSStyle.FileInfo.Extension[".vba"] = "`e[38;5;81m"
$PSStyle.FileInfo.Extension[".vbs"] = "`e[38;5;81m"
$PSStyle.FileInfo.Extension[".dockerignore"] = "`e[38;5;240m"
$PSStyle.FileInfo.Extension[".nix"] = "`e[38;5;155m"
$PSStyle.FileInfo.Extension[".dhall"] = "`e[38;5;178m"
$PSStyle.FileInfo.Extension[".rake"] = "`e[38;5;155m"
$PSStyle.FileInfo.Extension[".am"] = "`e[38;5;242m"
$PSStyle.FileInfo.Extension[".in"] = "`e[38;5;242m"
$PSStyle.FileInfo.Extension[".hin"] = "`e[38;5;242m"
$PSStyle.FileInfo.Extension[".scan"] = "`e[38;5;242m"
$PSStyle.FileInfo.Extension[".m4"] = "`e[38;5;242m"
$PSStyle.FileInfo.Extension[".old"] = "`e[38;5;242m"
$PSStyle.FileInfo.Extension[".out"] = "`e[38;5;242m"
$PSStyle.FileInfo.Extension[".SKIP"] = "`e[38;5;244m"
$PSStyle.FileInfo.Extension[".diff"] = "`e[48;5;197;38;5;232m"
$PSStyle.FileInfo.Extension[".patch"] = "`e[48;5;197;38;5;232;1m"
$PSStyle.FileInfo.Extension[".bmp"] = "`e[38;5;97m"
$PSStyle.FileInfo.Extension[".dicom"] = "`e[38;5;97m"
$PSStyle.FileInfo.Extension[".tiff"] = "`e[38;5;97m"
$PSStyle.FileInfo.Extension[".tif"] = "`e[38;5;97m"
$PSStyle.FileInfo.Extension[".TIFF"] = "`e[38;5;97m"
$PSStyle.FileInfo.Extension[".cdr"] = "`e[38;5;97m"
$PSStyle.FileInfo.Extension[".flif"] = "`e[38;5;97m"
$PSStyle.FileInfo.Extension[".gif"] = "`e[38;5;97m"
$PSStyle.FileInfo.Extension[".icns"] = "`e[38;5;97m"
$PSStyle.FileInfo.Extension[".ico"] = "`e[38;5;97m"
$PSStyle.FileInfo.Extension[".jpeg"] = "`e[38;5;97m"
$PSStyle.FileInfo.Extension[".JPG"] = "`e[38;5;97m"
$PSStyle.FileInfo.Extension[".jpg"] = "`e[38;5;97m"
$PSStyle.FileInfo.Extension[".jxl"] = "`e[38;5;97m"
$PSStyle.FileInfo.Extension[".nth"] = "`e[38;5;97m"
$PSStyle.FileInfo.Extension[".png"] = "`e[38;5;97m"
$PSStyle.FileInfo.Extension[".psd"] = "`e[38;5;97m"
$PSStyle.FileInfo.Extension[".pxd"] = "`e[38;5;97m"
$PSStyle.FileInfo.Extension[".pxm"] = "`e[38;5;97m"
$PSStyle.FileInfo.Extension[".xpm"] = "`e[38;5;97m"
$PSStyle.FileInfo.Extension[".webp"] = "`e[38;5;97m"
$PSStyle.FileInfo.Extension[".ai"] = "`e[38;5;99m"
$PSStyle.FileInfo.Extension[".eps"] = "`e[38;5;99m"
$PSStyle.FileInfo.Extension[".epsf"] = "`e[38;5;99m"
$PSStyle.FileInfo.Extension[".drw"] = "`e[38;5;99m"
$PSStyle.FileInfo.Extension[".ps"] = "`e[38;5;99m"
$PSStyle.FileInfo.Extension[".svg"] = "`e[38;5;99m"
$PSStyle.FileInfo.Extension[".avi"] = "`e[38;5;114m"
$PSStyle.FileInfo.Extension[".divx"] = "`e[38;5;114m"
$PSStyle.FileInfo.Extension[".IFO"] = "`e[38;5;114m"
$PSStyle.FileInfo.Extension[".m2v"] = "`e[38;5;114m"
$PSStyle.FileInfo.Extension[".m4v"] = "`e[38;5;114m"
$PSStyle.FileInfo.Extension[".mkv"] = "`e[38;5;114m"
$PSStyle.FileInfo.Extension[".MOV"] = "`e[38;5;114m"
$PSStyle.FileInfo.Extension[".mov"] = "`e[38;5;114m"
$PSStyle.FileInfo.Extension[".mp4"] = "`e[38;5;114m"
$PSStyle.FileInfo.Extension[".mpeg"] = "`e[38;5;114m"
$PSStyle.FileInfo.Extension[".mpg"] = "`e[38;5;114m"
$PSStyle.FileInfo.Extension[".ogm"] = "`e[38;5;114m"
$PSStyle.FileInfo.Extension[".rmvb"] = "`e[38;5;114m"
$PSStyle.FileInfo.Extension[".sample"] = "`e[38;5;114m"
$PSStyle.FileInfo.Extension[".wmv"] = "`e[38;5;114m"
$PSStyle.FileInfo.Extension[".3g2"] = "`e[38;5;115m"
$PSStyle.FileInfo.Extension[".3gp"] = "`e[38;5;115m"
$PSStyle.FileInfo.Extension[".gp3"] = "`e[38;5;115m"
$PSStyle.FileInfo.Extension[".webm"] = "`e[38;5;115m"
$PSStyle.FileInfo.Extension[".gp4"] = "`e[38;5;115m"
$PSStyle.FileInfo.Extension[".asf"] = "`e[38;5;115m"
$PSStyle.FileInfo.Extension[".flv"] = "`e[38;5;115m"
$PSStyle.FileInfo.Extension[".ts"] = "`e[38;5;115m"
$PSStyle.FileInfo.Extension[".ogv"] = "`e[38;5;115m"
$PSStyle.FileInfo.Extension[".f4v"] = "`e[38;5;115m"
$PSStyle.FileInfo.Extension[".VOB"] = "`e[38;5;115;1m"
$PSStyle.FileInfo.Extension[".vob"] = "`e[38;5;115;1m"
$PSStyle.FileInfo.Extension[".ass"] = "`e[38;5;117m"
$PSStyle.FileInfo.Extension[".srt"] = "`e[38;5;117m"
$PSStyle.FileInfo.Extension[".ssa"] = "`e[38;5;117m"
$PSStyle.FileInfo.Extension[".sub"] = "`e[38;5;117m"
$PSStyle.FileInfo.Extension[".sup"] = "`e[38;5;117m"
$PSStyle.FileInfo.Extension[".vtt"] = "`e[38;5;117m"
$PSStyle.FileInfo.Extension[".3ga"] = "`e[38;5;137;1m"
$PSStyle.FileInfo.Extension[".S3M"] = "`e[38;5;137;1m"
$PSStyle.FileInfo.Extension[".aac"] = "`e[38;5;137;1m"
$PSStyle.FileInfo.Extension[".amr"] = "`e[38;5;137;1m"
$PSStyle.FileInfo.Extension[".au"] = "`e[38;5;137;1m"
$PSStyle.FileInfo.Extension[".caf"] = "`e[38;5;137;1m"
$PSStyle.FileInfo.Extension[".dat"] = "`e[38;5;137;1m"
$PSStyle.FileInfo.Extension[".dts"] = "`e[38;5;137;1m"
$PSStyle.FileInfo.Extension[".fcm"] = "`e[38;5;137;1m"
$PSStyle.FileInfo.Extension[".m4a"] = "`e[38;5;137;1m"
$PSStyle.FileInfo.Extension[".mod"] = "`e[38;5;137;1m"
$PSStyle.FileInfo.Extension[".mp3"] = "`e[38;5;137;1m"
$PSStyle.FileInfo.Extension[".mp4a"] = "`e[38;5;137;1m"
$PSStyle.FileInfo.Extension[".oga"] = "`e[38;5;137;1m"
$PSStyle.FileInfo.Extension[".ogg"] = "`e[38;5;137;1m"
$PSStyle.FileInfo.Extension[".opus"] = "`e[38;5;137;1m"
$PSStyle.FileInfo.Extension[".s3m"] = "`e[38;5;137;1m"
$PSStyle.FileInfo.Extension[".sid"] = "`e[38;5;137;1m"
$PSStyle.FileInfo.Extension[".wma"] = "`e[38;5;137;1m"
$PSStyle.FileInfo.Extension[".ape"] = "`e[38;5;136;1m"
$PSStyle.FileInfo.Extension[".aiff"] = "`e[38;5;136;1m"
$PSStyle.FileInfo.Extension[".cda"] = "`e[38;5;136;1m"
$PSStyle.FileInfo.Extension[".flac"] = "`e[38;5;136;1m"
$PSStyle.FileInfo.Extension[".alac"] = "`e[38;5;136;1m"
$PSStyle.FileInfo.Extension[".mid"] = "`e[38;5;136;1m"
$PSStyle.FileInfo.Extension[".midi"] = "`e[38;5;136;1m"
$PSStyle.FileInfo.Extension[".pcm"] = "`e[38;5;136;1m"
$PSStyle.FileInfo.Extension[".wav"] = "`e[38;5;136;1m"
$PSStyle.FileInfo.Extension[".wv"] = "`e[38;5;136;1m"
$PSStyle.FileInfo.Extension[".wvc"] = "`e[38;5;136;1m"
$PSStyle.FileInfo.Extension[".afm"] = "`e[38;5;66m"
$PSStyle.FileInfo.Extension[".fon"] = "`e[38;5;66m"
$PSStyle.FileInfo.Extension[".fnt"] = "`e[38;5;66m"
$PSStyle.FileInfo.Extension[".pfb"] = "`e[38;5;66m"
$PSStyle.FileInfo.Extension[".pfm"] = "`e[38;5;66m"
$PSStyle.FileInfo.Extension[".ttf"] = "`e[38;5;66m"
$PSStyle.FileInfo.Extension[".otf"] = "`e[38;5;66m"
$PSStyle.FileInfo.Extension[".woff"] = "`e[38;5;66m"
$PSStyle.FileInfo.Extension[".woff2"] = "`e[38;5;66m"
$PSStyle.FileInfo.Extension[".PFA"] = "`e[38;5;66m"
$PSStyle.FileInfo.Extension[".pfa"] = "`e[38;5;66m"
$PSStyle.FileInfo.Extension[".7z"] = "`e[38;5;40m"
$PSStyle.FileInfo.Extension[".a"] = "`e[38;5;40m"
$PSStyle.FileInfo.Extension[".arj"] = "`e[38;5;40m"
$PSStyle.FileInfo.Extension[".bz2"] = "`e[38;5;40m"
$PSStyle.FileInfo.Extension[".cpio"] = "`e[38;5;40m"
$PSStyle.FileInfo.Extension[".gz"] = "`e[38;5;40m"
$PSStyle.FileInfo.Extension[".lrz"] = "`e[38;5;40m"
$PSStyle.FileInfo.Extension[".lz"] = "`e[38;5;40m"
$PSStyle.FileInfo.Extension[".lzma"] = "`e[38;5;40m"
$PSStyle.FileInfo.Extension[".lzo"] = "`e[38;5;40m"
$PSStyle.FileInfo.Extension[".rar"] = "`e[38;5;40m"
$PSStyle.FileInfo.Extension[".s7z"] = "`e[38;5;40m"
$PSStyle.FileInfo.Extension[".sz"] = "`e[38;5;40m"
$PSStyle.FileInfo.Extension[".tar"] = "`e[38;5;40m"
$PSStyle.FileInfo.Extension[".tbz"] = "`e[38;5;40m"
$PSStyle.FileInfo.Extension[".tgz"] = "`e[38;5;40m"
$PSStyle.FileInfo.Extension[".warc"] = "`e[38;5;40m"
$PSStyle.FileInfo.Extension[".WARC"] = "`e[38;5;40m"
$PSStyle.FileInfo.Extension[".xz"] = "`e[38;5;40m"
$PSStyle.FileInfo.Extension[".z"] = "`e[38;5;40m"
$PSStyle.FileInfo.Extension[".zip"] = "`e[38;5;40m"
$PSStyle.FileInfo.Extension[".zipx"] = "`e[38;5;40m"
$PSStyle.FileInfo.Extension[".zoo"] = "`e[38;5;40m"
$PSStyle.FileInfo.Extension[".zpaq"] = "`e[38;5;40m"
$PSStyle.FileInfo.Extension[".zst"] = "`e[38;5;40m"
$PSStyle.FileInfo.Extension[".zstd"] = "`e[38;5;40m"
$PSStyle.FileInfo.Extension[".zz"] = "`e[38;5;40m"
$PSStyle.FileInfo.Extension[".apk"] = "`e[38;5;215m"
$PSStyle.FileInfo.Extension[".ipa"] = "`e[38;5;215m"
$PSStyle.FileInfo.Extension[".deb"] = "`e[38;5;215m"
$PSStyle.FileInfo.Extension[".rpm"] = "`e[38;5;215m"
$PSStyle.FileInfo.Extension[".jad"] = "`e[38;5;215m"
$PSStyle.FileInfo.Extension[".jar"] = "`e[38;5;215m"
$PSStyle.FileInfo.Extension[".ear"] = "`e[38;5;215m"
$PSStyle.FileInfo.Extension[".war"] = "`e[38;5;215m"
$PSStyle.FileInfo.Extension[".cab"] = "`e[38;5;215m"
$PSStyle.FileInfo.Extension[".pak"] = "`e[38;5;215m"
$PSStyle.FileInfo.Extension[".pk3"] = "`e[38;5;215m"
$PSStyle.FileInfo.Extension[".vdf"] = "`e[38;5;215m"
$PSStyle.FileInfo.Extension[".vpk"] = "`e[38;5;215m"
$PSStyle.FileInfo.Extension[".bsp"] = "`e[38;5;215m"
$PSStyle.FileInfo.Extension[".dmg"] = "`e[38;5;215m"
$PSStyle.FileInfo.Extension[".crx"] = "`e[38;5;215m"
$PSStyle.FileInfo.Extension[".xpi"] = "`e[38;5;215m"
$PSStyle.FileInfo.Extension[".iso"] = "`e[38;5;124m"
$PSStyle.FileInfo.Extension[".img"] = "`e[38;5;124m"
$PSStyle.FileInfo.Extension[".bin"] = "`e[38;5;124m"
$PSStyle.FileInfo.Extension[".nrg"] = "`e[38;5;124m"
$PSStyle.FileInfo.Extension[".qcow"] = "`e[38;5;124m"
$PSStyle.FileInfo.Extension[".fvd"] = "`e[38;5;124m"
$PSStyle.FileInfo.Extension[".sparseimage"] = "`e[38;5;124m"
$PSStyle.FileInfo.Extension[".toast"] = "`e[38;5;124m"
$PSStyle.FileInfo.Extension[".vcd"] = "`e[38;5;124m"
$PSStyle.FileInfo.Extension[".vdi"] = "`e[38;5;124m"
$PSStyle.FileInfo.Extension[".vhd"] = "`e[38;5;124m"
$PSStyle.FileInfo.Extension[".vhdx"] = "`e[38;5;124m"
$PSStyle.FileInfo.Extension[".vfd"] = "`e[38;5;124m"
$PSStyle.FileInfo.Extension[".vmdk"] = "`e[38;5;124m"
$PSStyle.FileInfo.Extension[".swp"] = "`e[38;5;244m"
$PSStyle.FileInfo.Extension[".swo"] = "`e[38;5;244m"
$PSStyle.FileInfo.Extension[".tmp"] = "`e[38;5;244m"
$PSStyle.FileInfo.Extension[".sassc"] = "`e[38;5;244m"
$PSStyle.FileInfo.Extension[".pacnew"] = "`e[38;5;33m"
$PSStyle.FileInfo.Extension[".un~"] = "`e[38;5;241m"
$PSStyle.FileInfo.Extension[".orig"] = "`e[38;5;241m"
$PSStyle.FileInfo.Extension[".BUP"] = "`e[38;5;241m"
$PSStyle.FileInfo.Extension[".bak"] = "`e[38;5;241m"
$PSStyle.FileInfo.Extension[".o"] = "`e[38;5;241m"
$PSStyle.FileInfo.Extension[".mdump"] = "`e[38;5;241m"
$PSStyle.FileInfo.Extension[".rlib"] = "`e[38;5;241m"
$PSStyle.FileInfo.Extension[".dll"] = "`e[38;5;241m"
$PSStyle.FileInfo.Extension[".aria2"] = "`e[38;5;241m"
$PSStyle.FileInfo.Extension[".dump"] = "`e[38;5;241m"
$PSStyle.FileInfo.Extension[".stackdump"] = "`e[38;5;241m"
$PSStyle.FileInfo.Extension[".zcompdump"] = "`e[38;5;241m"
$PSStyle.FileInfo.Extension[".zwc"] = "`e[38;5;241m"
$PSStyle.FileInfo.Extension[".part"] = "`e[38;5;239m"
$PSStyle.FileInfo.Extension[".r[0-9]{0,2}"] = "`e[38;5;239m"
$PSStyle.FileInfo.Extension[".zx[0-9]{0,2}"] = "`e[38;5;239m"
$PSStyle.FileInfo.Extension[".z[0-9]{0,2}"] = "`e[38;5;239m"
$PSStyle.FileInfo.Extension[".pid"] = "`e[38;5;248m"
$PSStyle.FileInfo.Extension[".state"] = "`e[38;5;248m"
$PSStyle.FileInfo.Extension[".err"] = "`e[38;5;160;1m"
$PSStyle.FileInfo.Extension[".error"] = "`e[38;5;160;1m"
$PSStyle.FileInfo.Extension[".stderr"] = "`e[38;5;160;1m"
$PSStyle.FileInfo.Extension[".pcap"] = "`e[38;5;29m"
$PSStyle.FileInfo.Extension[".cap"] = "`e[38;5;29m"
$PSStyle.FileInfo.Extension[".dmp"] = "`e[38;5;29m"
$PSStyle.FileInfo.Extension[".allow"] = "`e[38;5;112m"
$PSStyle.FileInfo.Extension[".deny"] = "`e[38;5;196m"
$PSStyle.FileInfo.Extension[".service"] = "`e[38;5;45m"
$PSStyle.FileInfo.Extension[".socket"] = "`e[38;5;45m"
$PSStyle.FileInfo.Extension[".swap"] = "`e[38;5;45m"
$PSStyle.FileInfo.Extension[".device"] = "`e[38;5;45m"
$PSStyle.FileInfo.Extension[".mount"] = "`e[38;5;45m"
$PSStyle.FileInfo.Extension[".automount"] = "`e[38;5;45m"
$PSStyle.FileInfo.Extension[".target"] = "`e[38;5;45m"
$PSStyle.FileInfo.Extension[".path"] = "`e[38;5;45m"
$PSStyle.FileInfo.Extension[".timer"] = "`e[38;5;45m"
$PSStyle.FileInfo.Extension[".snapshot"] = "`e[38;5;45m"
$PSStyle.FileInfo.Extension[".lnk"] = "`e[38;5;39m"
$PSStyle.FileInfo.Extension[".application"] = "`e[38;5;116m"
$PSStyle.FileInfo.Extension[".cue"] = "`e[38;5;116m"
$PSStyle.FileInfo.Extension[".description"] = "`e[38;5;116m"
$PSStyle.FileInfo.Extension[".directory"] = "`e[38;5;116m"
$PSStyle.FileInfo.Extension[".m3u"] = "`e[38;5;116m"
$PSStyle.FileInfo.Extension[".m3u8"] = "`e[38;5;116m"
$PSStyle.FileInfo.Extension[".md5"] = "`e[38;5;116m"
$PSStyle.FileInfo.Extension[".properties"] = "`e[38;5;116m"
$PSStyle.FileInfo.Extension[".sfv"] = "`e[38;5;116m"
$PSStyle.FileInfo.Extension[".theme"] = "`e[38;5;116m"
$PSStyle.FileInfo.Extension[".torrent"] = "`e[38;5;116m"
$PSStyle.FileInfo.Extension[".urlview"] = "`e[38;5;116m"
$PSStyle.FileInfo.Extension[".webloc"] = "`e[38;5;116m"
$PSStyle.FileInfo.Extension[".asc"] = "`e[38;5;192;3m"
$PSStyle.FileInfo.Extension[".bfe"] = "`e[38;5;192;3m"
$PSStyle.FileInfo.Extension[".enc"] = "`e[38;5;192;3m"
$PSStyle.FileInfo.Extension[".gpg"] = "`e[38;5;192;3m"
$PSStyle.FileInfo.Extension[".signature"] = "`e[38;5;192;3m"
$PSStyle.FileInfo.Extension[".sig"] = "`e[38;5;192;3m"
$PSStyle.FileInfo.Extension[".p12"] = "`e[38;5;192;3m"
$PSStyle.FileInfo.Extension[".pem"] = "`e[38;5;192;3m"
$PSStyle.FileInfo.Extension[".pgp"] = "`e[38;5;192;3m"
$PSStyle.FileInfo.Extension[".p7s"] = "`e[38;5;192;3m"
$PSStyle.FileInfo.Extension[".32x"] = "`e[38;5;213m"
$PSStyle.FileInfo.Extension[".cdi"] = "`e[38;5;213m"
$PSStyle.FileInfo.Extension[".fm2"] = "`e[38;5;213m"
$PSStyle.FileInfo.Extension[".rom"] = "`e[38;5;213m"
$PSStyle.FileInfo.Extension[".sav"] = "`e[38;5;213m"
$PSStyle.FileInfo.Extension[".st"] = "`e[38;5;213m"
$PSStyle.FileInfo.Extension[".a00"] = "`e[38;5;213m"
$PSStyle.FileInfo.Extension[".a52"] = "`e[38;5;213m"
$PSStyle.FileInfo.Extension[".A64"] = "`e[38;5;213m"
$PSStyle.FileInfo.Extension[".a64"] = "`e[38;5;213m"
$PSStyle.FileInfo.Extension[".a78"] = "`e[38;5;213m"
$PSStyle.FileInfo.Extension[".adf"] = "`e[38;5;213m"
$PSStyle.FileInfo.Extension[".atr"] = "`e[38;5;213m"
$PSStyle.FileInfo.Extension[".gb"] = "`e[38;5;213m"
$PSStyle.FileInfo.Extension[".gba"] = "`e[38;5;213m"
$PSStyle.FileInfo.Extension[".gbc"] = "`e[38;5;213m"
$PSStyle.FileInfo.Extension[".gel"] = "`e[38;5;213m"
$PSStyle.FileInfo.Extension[".gg"] = "`e[38;5;213m"
$PSStyle.FileInfo.Extension[".ggl"] = "`e[38;5;213m"
$PSStyle.FileInfo.Extension[".ipk"] = "`e[38;5;213m"
$PSStyle.FileInfo.Extension[".j64"] = "`e[38;5;213m"
$PSStyle.FileInfo.Extension[".nds"] = "`e[38;5;213m"
$PSStyle.FileInfo.Extension[".nes"] = "`e[38;5;213m"
$PSStyle.FileInfo.Extension[".sms"] = "`e[38;5;213m"
$PSStyle.FileInfo.Extension[".8xp"] = "`e[38;5;121m"
$PSStyle.FileInfo.Extension[".8eu"] = "`e[38;5;121m"
$PSStyle.FileInfo.Extension[".82p"] = "`e[38;5;121m"
$PSStyle.FileInfo.Extension[".83p"] = "`e[38;5;121m"
$PSStyle.FileInfo.Extension[".8xe"] = "`e[38;5;121m"
$PSStyle.FileInfo.Extension[".stl"] = "`e[38;5;216m"
$PSStyle.FileInfo.Extension[".dwg"] = "`e[38;5;216m"
$PSStyle.FileInfo.Extension[".ply"] = "`e[38;5;216m"
$PSStyle.FileInfo.Extension[".wrl"] = "`e[38;5;216m"
$PSStyle.FileInfo.Extension[".xib"] = "`e[38;5;208m"
$PSStyle.FileInfo.Extension[".iml"] = "`e[38;5;166m"
$PSStyle.FileInfo.Extension[".DS_Store"] = "`e[38;5;239m"
$PSStyle.FileInfo.Extension[".localized"] = "`e[38;5;239m"
$PSStyle.FileInfo.Extension[".CFUserTextEncoding"] = "`e[38;5;239m"
$PSStyle.FileInfo.Extension[".nib"] = "`e[38;5;57m"
$PSStyle.FileInfo.Extension[".car"] = "`e[38;5;57m"
$PSStyle.FileInfo.Extension[".dylib"] = "`e[38;5;241m"
$PSStyle.FileInfo.Extension[".entitlements"] = "`e[1m"
$PSStyle.FileInfo.Extension[".pbxproj"] = "`e[1m"
$PSStyle.FileInfo.Extension[".strings"] = "`e[1m"
$PSStyle.FileInfo.Extension[".storyboard"] = "`e[38;5;196m"
$PSStyle.FileInfo.Extension[".xcconfig"] = "`e[1m"
$PSStyle.FileInfo.Extension[".xcsettings"] = "`e[1m"
$PSStyle.FileInfo.Extension[".xcuserstate"] = "`e[1m"
$PSStyle.FileInfo.Extension[".xcworkspacedata"] = "`e[1m"
$PSStyle.FileInfo.Extension[".pot"] = "`e[38;5;7m"
$PSStyle.FileInfo.Extension[".pcb"] = "`e[38;5;7m"
$PSStyle.FileInfo.Extension[".mm"] = "`e[38;5;7m"
$PSStyle.FileInfo.Extension[".gbr"] = "`e[38;5;7m"
$PSStyle.FileInfo.Extension[".scm"] = "`e[38;5;7m"
$PSStyle.FileInfo.Extension[".xcf"] = "`e[38;5;7m"
$PSStyle.FileInfo.Extension[".spl"] = "`e[38;5;7m"
$PSStyle.FileInfo.Extension[".Rproj"] = "`e[38;5;11m"
$PSStyle.FileInfo.Extension[".sis"] = "`e[38;5;7m"
$PSStyle.FileInfo.Extension[".1p"] = "`e[38;5;7m"
$PSStyle.FileInfo.Extension[".3p"] = "`e[38;5;7m"
$PSStyle.FileInfo.Extension[".cnc"] = "`e[38;5;7m"
$PSStyle.FileInfo.Extension[".def"] = "`e[38;5;7m"
$PSStyle.FileInfo.Extension[".ex"] = "`e[38;5;7m"
$PSStyle.FileInfo.Extension[".example"] = "`e[38;5;7m"
$PSStyle.FileInfo.Extension[".feature"] = "`e[38;5;7m"
$PSStyle.FileInfo.Extension[".ger"] = "`e[38;5;7m"
$PSStyle.FileInfo.Extension[".ics"] = "`e[38;5;7m"
$PSStyle.FileInfo.Extension[".map"] = "`e[38;5;7m"
$PSStyle.FileInfo.Extension[".mf"] = "`e[38;5;7m"
$PSStyle.FileInfo.Extension[".mfasl"] = "`e[38;5;7m"
$PSStyle.FileInfo.Extension[".mi"] = "`e[38;5;7m"
$PSStyle.FileInfo.Extension[".mtx"] = "`e[38;5;7m"
$PSStyle.FileInfo.Extension[".pc"] = "`e[38;5;7m"
$PSStyle.FileInfo.Extension[".pi"] = "`e[38;5;7m"
$PSStyle.FileInfo.Extension[".plt"] = "`e[38;5;7m"
$PSStyle.FileInfo.Extension[".rdf"] = "`e[38;5;7m"
$PSStyle.FileInfo.Extension[".ru"] = "`e[38;5;7m"
$PSStyle.FileInfo.Extension[".sch"] = "`e[38;5;7m"
$PSStyle.FileInfo.Extension[".sty"] = "`e[38;5;7m"
$PSStyle.FileInfo.Extension[".sug"] = "`e[38;5;7m"
$PSStyle.FileInfo.Extension[".tdy"] = "`e[38;5;7m"
$PSStyle.FileInfo.Extension[".tfm"] = "`e[38;5;7m"
$PSStyle.FileInfo.Extension[".tfnt"] = "`e[38;5;7m"
$PSStyle.FileInfo.Extension[".tg"] = "`e[38;5;7m"
$PSStyle.FileInfo.Extension[".vcard"] = "`e[38;5;7m"
$PSStyle.FileInfo.Extension[".vcf"] = "`e[38;5;7m"
$PSStyle.FileInfo.Extension[".xln"] = "`e[38;5;7m"

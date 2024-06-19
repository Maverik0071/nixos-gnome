# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, modulesPath, lib, inputs, flakes, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # amdgpu setup
  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  hardware.opengl.extraPackages = with pkgs; [
  amdvlk
  ];
  # For 32 bit applications 
  hardware.opengl.extraPackages32 = with pkgs; [
  driversi686Linux.amdvlk
  ];
   
  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["amdgpu"];
  
  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    powerManagement.enable = false;
    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
	# accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Bootloader.
  #boot.loader.systemd-boot.enable = true;
  #boot.loader.systemd-boot.extraEntries = { };
  #boot.loader.efi.canTouchEfiVariables = true;
  #boot.loader.efi.efiSysMountPoint = "/boot";
  # boot.initrd.kernelModules = [" amdgpu "];
  boot.loader = {
  grub = {
    enable = true;
    useOSProber = true;
    devices = [ "nodev" ];
    efiSupport = true;
    configurationLimit = 5;
  };
  efi.canTouchEfiVariables = true;
};
  boot.initrd.kernelModules = [ "amdgpu"];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  #direnv
  programs.direnv.enable = true;
  programs.direnv.loadInNixShell = true;
  programs.direnv.nix-direnv.enable = true;
  programs.direnv.silent = true;    

  networking.hostName = "wolvesden"; # Define your hostname.
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Detroit";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  #services.xserver.autorun = true;
  #services.xserver.layout = "us";
  #services.xserver.desktopManager.default = "none";
  #services.xserver.desktopManager.xterm.enabe = false;
  #services.xserver.displayManager.lightdm.enable = true;
  services.xserver.windowManager.i3.enable = true;
  #services.xserver.displayManager.sddm.enable = true;
  #services.xserver.displayManager.sddm.wayland.enable = true;
  # services.xserver.displayManager.sddm.theme = "breeze";
  # services.xserver.displayManager.ly.enable = true;  
  # services.xserver.videoDrivers = [ "amdgpu" ];

  # gnome desktop
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.dbus.packages = with pkgs; [ gnome2.GConf ];
  programs.dconf.enable = true;
  #environment.systemPackages = with pkgs; [ gnomeExtensions.appindicator ];
  services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];
  nixpkgs.config.allowAliases = false;
  services.sysprof.enable = true;
  nixpkgs.config.firefox.enableGnomeExtensions = true;
  #services.gnome.chrome-gnome-shell.enable = true;
  #services.gnome.gnome-browser-connector.enable = true;

  # Enable the XFCE Desktop Environment.
  # services.xserver.displayManager.lightdm.enable = true;
  #services.xserver.desktopManager.xfce.enable = true;
  
  # hyprland
  # programs.hyprland.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # enable flatpak
  services.flatpak.enable = true;
  xdg.portal.enable = true;
  
  # xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
  #xdg.portal.config.common.default = "gtk";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.densetsu = {
    isNormalUser = true;
    description = "densetsu";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
      #ungoogled-chromium
      #brave
      acsccid
      #scmccid
      lunarvim
      zsh
      gh
    #  thunderbird
    ];
  };

  # for virtualization like gnome-boces or virt-manager
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  
  #spices (virtualization)
  services.spice-vdagentd.enable = true;  
  
  # LF file manager
  # programs.lf.enable = true;

  # ZRAM
  zramSwap.enable = true;

  #nvidia



  # zsh terminal
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable Flakes and the command-line tool with nix command settings 
  nix.settings.experimental-features = [ "nix-command flakes"];
  
   # Set default editor to vim
  environment.variables.EDITOR = "lvim";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
     #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
   # bash and zsh 
    nix-bash-completions
    nix-zsh-completions
    zsh-autocomplete
    zsh-autosuggestions
    zsh-powerlevel10k
    zsh-syntax-highlighting
    zsh-history-substring-search
    zsh-fast-syntax-highlighting
    nixd
    zsh-nix-shell
    nix-search-cli
    pkgs.nvd
    nix-output-monitor
    nix-top
    nix-doc
    nix-pin
    nix-tree
    nix-melt
    nix-info
    nix-diff
    nix-serve
    nix-index
    nix-update
    nix-script
    nix-bundle
    nixos-icons
    nixos-shell
    nix-plugins
    nixpkgs-lint
    nixos-option
    nom
    nitch
    nh

  # gnome software
    gnome.gnome-software
    gnome-extension-manager
    gnome.gnome-packagekit
    gnome.gnome-tweaks
    gnomeExtensions.dock-reloaded
    qgnomeplatform-qt6
    qgnomeplatform
    gnomeExtensions.forge
  # xdg-desktop-portal-gnome
    lomiri.gmenuharness
  # gnome-gnome-settings-daemon

  #bootstrapping
    gzip
    wget
    curl
    pkgs.gh
    pkgs.libsForQt5.ark
    git
    vim
    arandr
    # pkgs.chromium
    meson
    gcc
    clang
    cl 
    zig
    cmake
    meson
    ninja
    libsForQt5.full
    libsForQt5.qt5.qtbase
    qt6.full
    lm_sensors
    xfce.xfce4-sensors-plugin
    xsensors
    qt6.qtbase
    fanctl
  # cope
    gnumake
    gnumake42

   #i3wm pkgs
    dmenu
    rofi
    autotiling
    lxappearance
    xfce.xfce4-terminal
    xfce.xfce4-settings
    dunst
    pavucontrol
    jgmenu
    nix-zsh-completions
    zsh
    tmux
    fzf-zsh
    nitrogen
    pfetch
    neofetch
    neovim
    picom
    networkmanager_dmenu
    papirus-folders
    papirus-nord
    sweet
    clipmenu
    volumeicon
    brightnessctl

  # fonts and themes
    hermit
    source-code-pro
    terminus_font
    nerdfonts
    terminus-nerdfont
    ranger
    i3status
    pkgs.pcscliteWithPolkit
    pkgs.pcsc-tools
    pkgs.scmccid
    pkgs.ccid
    pkgs.pcsclite
    pkgs.opensc
    starship
    nixos-icons
    material-icons
    material-design-icons
    luna-icons
    variety
    sweet

   #vim and programming 
    vimPlugins.nvim-treesitter-textsubjects
    nixos-install-tools
    nodejs_22
    lua
    python3
    clipit
    pkgs.volumeicon
    rofi-power-menu
    blueberry

   #misc
    steam
    pkgs.steamPackages.steam-runtime
    sc-controller
    gamescope
    protonup-qt
    lutris
    steamtinkerlaunch
    gh
    pasystray
    tlp
    pkgs.ly
    dhcpdump
    btop
    postgresql
    w3m
    usbimager
    wezterm
    xdragon
    lunarvim
    # pcsctools
    pcsclite
    pkgs.opensc
  # pkgs.ark
    pam_p11
    #pam_usb
    nss
    nss_latest
    distrobox
    fzf-zsh
   # nvidia driver
   # nvidia_x11
   # nvidia-settings
   # nvidia-persistenced
   # lshw
   #hyprland
    xdg-desktop-portal-hyprland
    rPackages.gbm
    hyprland-protocols
    libdrm
    wayland-protocols
    waybar
    wofi
    kitty
    kitty-themes
    swaybg
   #waybar
    gtkmm3
    gtk-layer-shell
    jsoncpp
    fmt
    wayland
    spdlog
    # libgtk-3-dev #[gtk-layer-shell]
    gobject-introspection #[gtk-layer-shell]
    # libpulse #[Pulseaudio module]
    libnl #[Network module]
    libappindicator-gtk3 #[Tray module]
    libdbusmenu-gtk3 #[Tray module]
    libmpdclient #[MPD module]
    # libsndio #[sndio module# ]
    libevdev #[KeyboardState module]
    # xkbregistry
    upower #[UPower battery module]
    nwg-look
    feh
    wl-clipboard
    wlogout 
   ];

    fonts = {
    fonts = with pkgs; [
      noto-fonts
   #  noto-fonts-cjk
   #  noto-fonts-emoji
      font-awesome
      font-awesome_5
      font-awesome_4
      source-han-sans
      open-sans
   #  source-han-sans-japanese
   #  source-han-serif-japanese
      openmoji-color
    ];
    fontconfig.defaultFonts = {
      serif = [ "Noto Serif" "Source Han Serif" ];
      sansSerif = [ "Open Sans" "Source Han Sans" ];
      emoji = [ "openmoji-color" ];
    };
  };    

    programs.starship.enable = true;

    environment.sessionVariables = {
    dotfiles = "/etc/nixos/configuration.nix";
  };

   # nix grub generations
   system.autoUpgrade.enable = true;
   system.autoUpgrade.operation = "boot";
   system.autoUpgrade.dates = "24:00";
   # nix.settings.auto-optimise-store = true;
   nix.gc = {
   automatic = true;
   dates = "Sun 24:00";
   options = "--delete-older-than 7d";
  };

    nixpkgs.config.permittedInsecurePackages = [
    "nodejs-12.22.12"
    "python-2.7.18.7"
    "nix-2.17.1"
  ];
    

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:
    services.sshd.enable = true;
   # services.tlp.enable = true;
    services.pcscd.enable = true;
    security.pam.p11.enable = true;

  #gnome services
  services.xserver.displayManager.gdm.autoSuspend = true;
  programs.gnome-disks.enable = true;
  services.gnome.core-shell.enable = true;
  services.gnome.core-utilities.enable = true;
  services.gnome.gnome-settings-daemon.enable = true;
  services.gnome.gnome-user-share.enable = true;
  services.system76-scheduler.settings.processScheduler.foregroundBoost.enable = true;
  services.gnome.gnome-remote-desktop.enable = true;
  services.gnome.core-os-services.enable = true;
  services.gnome.gnome-online-accounts.enable = true;
  programs.file-roller.enable = true;
  qt.platformTheme = [
  "gnome"
  "gtk2"
  "gt5ct"
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.ports = [
  	22
   ];

  # Open ports in the firewall.
   networking.firewall.allowedTCPPorts = [ 22 80 443 ];
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}

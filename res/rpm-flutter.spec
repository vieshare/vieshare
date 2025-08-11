Name:       vieshare
Version:    1.4.1
Release:    0
Summary:    RPM package
License:    GPL-3.0
URL:        https://vieshare.com
Vendor:     vieshare <info@vieshare.com>
Requires:   gtk3 libxcb libxdo libXfixes alsa-lib libva pam gstreamer1-plugins-base
Recommends: libayatana-appindicator-gtk3
Provides:   libdesktop_drop_plugin.so()(64bit), libdesktop_multi_window_plugin.so()(64bit), libfile_selector_linux_plugin.so()(64bit), libflutter_custom_cursor_plugin.so()(64bit), libflutter_linux_gtk.so()(64bit), libscreen_retriever_plugin.so()(64bit), libtray_manager_plugin.so()(64bit), liburl_launcher_linux_plugin.so()(64bit), libwindow_manager_plugin.so()(64bit), libwindow_size_plugin.so()(64bit), libtexture_rgba_renderer_plugin.so()(64bit)

# https://docs.fedoraproject.org/en-US/packaging-guidelines/Scriptlets/

%description
The best open-source remote desktop client software, written in Rust.

%prep
# we have no source, so nothing here

%build
# we have no source, so nothing here

# %global __python %{__python3}

%install

mkdir -p "%{buildroot}/usr/share/vieshare" && cp -r ${HBB}/flutter/build/linux/x64/release/bundle/* -t "%{buildroot}/usr/share/vieshare"
mkdir -p "%{buildroot}/usr/bin"
install -Dm 644 $HBB/res/vieshare.service -t "%{buildroot}/usr/share/vieshare/files"
install -Dm 644 $HBB/res/vieshare.desktop -t "%{buildroot}/usr/share/vieshare/files"
install -Dm 644 $HBB/res/vieshare-link.desktop -t "%{buildroot}/usr/share/vieshare/files"
install -Dm 644 $HBB/res/128x128@2x.png "%{buildroot}/usr/share/icons/hicolor/256x256/apps/vieshare.png"
install -Dm 644 $HBB/res/scalable.svg "%{buildroot}/usr/share/icons/hicolor/scalable/apps/vieshare.svg"

%files
/usr/share/vieshare/*
/usr/share/vieshare/files/vieshare.service
/usr/share/icons/hicolor/256x256/apps/vieshare.png
/usr/share/icons/hicolor/scalable/apps/vieshare.svg
/usr/share/vieshare/files/vieshare.desktop
/usr/share/vieshare/files/vieshare-link.desktop

%changelog
# let's skip this for now

%pre
# can do something for centos7
case "$1" in
  1)
    # for install
  ;;
  2)
    # for upgrade
    systemctl stop vieshare || true
  ;;
esac

%post
cp /usr/share/vieshare/files/vieshare.service /etc/systemd/system/vieshare.service
cp /usr/share/vieshare/files/vieshare.desktop /usr/share/applications/
cp /usr/share/vieshare/files/vieshare-link.desktop /usr/share/applications/
ln -sf /usr/share/vieshare/vieshare /usr/bin/vieshare
systemctl daemon-reload
systemctl enable vieshare
systemctl start vieshare
update-desktop-database

%preun
case "$1" in
  0)
    # for uninstall
    systemctl stop vieshare || true
    systemctl disable vieshare || true
    rm /etc/systemd/system/vieshare.service || true
  ;;
  1)
    # for upgrade
  ;;
esac

%postun
case "$1" in
  0)
    # for uninstall
    rm /usr/bin/vieshare || true
    rmdir /usr/lib/vieshare || true
    rmdir /usr/local/vieshare || true
    rmdir /usr/share/vieshare || true
    rm /usr/share/applications/vieshare.desktop || true
    rm /usr/share/applications/vieshare-link.desktop || true
    update-desktop-database
  ;;
  1)
    # for upgrade
    rmdir /usr/lib/vieshare || true
    rmdir /usr/local/vieshare || true
  ;;
esac

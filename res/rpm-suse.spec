Name:       vieshare
Version:    1.1.9
Release:    0
Summary:    RPM package
License:    GPL-3.0
Requires:   gtk3 libxcb1 xdotool libXfixes3 alsa-utils libXtst6 libva2 pam gstreamer-plugins-base gstreamer-plugin-pipewire
Recommends: libayatana-appindicator3-1

# https://docs.fedoraproject.org/en-US/packaging-guidelines/Scriptlets/

%description
The best open-source remote desktop client software, written in Rust.

%prep
# we have no source, so nothing here

%build
# we have no source, so nothing here

%global __python %{__python3}

%install
mkdir -p %{buildroot}/usr/bin/
mkdir -p %{buildroot}/usr/share/vieshare/
mkdir -p %{buildroot}/usr/share/vieshare/files/
mkdir -p %{buildroot}/usr/share/icons/hicolor/256x256/apps/
mkdir -p %{buildroot}/usr/share/icons/hicolor/scalable/apps/
install -m 755 $HBB/target/release/vieshare %{buildroot}/usr/bin/vieshare
install $HBB/libsciter-gtk.so %{buildroot}/usr/share/vieshare/libsciter-gtk.so
install $HBB/res/vieshare.service %{buildroot}/usr/share/vieshare/files/
install $HBB/res/128x128@2x.png %{buildroot}/usr/share/icons/hicolor/256x256/apps/vieshare.png
install $HBB/res/scalable.svg %{buildroot}/usr/share/icons/hicolor/scalable/apps/vieshare.svg
install $HBB/res/vieshare.desktop %{buildroot}/usr/share/vieshare/files/
install $HBB/res/vieshare-link.desktop %{buildroot}/usr/share/vieshare/files/

%files
/usr/bin/vieshare
/usr/share/vieshare/libsciter-gtk.so
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
    rm /usr/share/applications/vieshare.desktop || true
    rm /usr/share/applications/vieshare-link.desktop || true
    update-desktop-database
  ;;
  1)
    # for upgrade
  ;;
esac

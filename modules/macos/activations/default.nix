{
  flake.modules.homeManager.darwin = {lib, ...}: {
    home.activation = {
      activateSettings = lib.hm.dag.entryAfter ["linkGeneration"] ''
        # activateSettings -u will reload the settings from the database and apply them to the current session,
        # so we do not need to logout and login again to make the changes take effect.
        /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
        export PATH=$PATH:/usr/bin
        /usr/bin/killall Dock || true
        /bin/sleep 1
        /usr/bin/open -ga /System/Library/CoreServices/Dock.app || true
      '';

      touchIdPrivilegeDisplayLinkFix = ''
        # https://www.reddit.com/r/macbookpro/comments/ld3rzr/comment/jigzlgx/
        /usr/bin/defaults write ~/Library/Preferences/com.apple.security.authorization.plist ignoreArd -bool TRUE
      '';
    };
  };
}

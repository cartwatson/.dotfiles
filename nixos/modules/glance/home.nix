{
  name = "Home";
  columns = [
    {
      size = "small";
      widgets = [
        {
          type = "calendar";
          "first-day-of-week" = "monday";
        }
        {
          type = "group";
          widgets = [
            {
              type = "bookmarks";
              groups = [
                {
                  title = "General";
                  color = "\${GRUVBOX_RED}";
                  links = [
                    { title = "Gmail"; url = "https://mail.google.com/mail/u/0/" ; }
                    { title = "Github"; url = "https://github.com/" ; }
                    { title = "Bitwarden"; url = "https://vault.bitwarden.com/#/vault" ; }
                  ];
                }
                {
                  title = "NPR";
                  color = "\${GRUVBOX_AQUA}";
                  links = [
                    { title = "World News"; url = "https://text.npr.org/1004" ; }
                    { title = "Science"; url = "https://text.npr.org/1007" ; }
                    { title = "Culture"; url = "https://text.npr.org/1008" ; }
                    { title = "Space"; url = "https://text.npr.org/1026" ; }
                    { title = "Mental Health"; url = "https://text.npr.org/1029" ; }
                  ];
                }
                {
                  title = "Social";
                  color = "\${GRUVBOX_PURPLE}";
                  links = [
                    { title = "LinkedIn"; url = "https://linkedin.com/" ; }
                    { title = "YouTube"; url = "https://youtube.com/" ; }
                    { title = "Instagram"; url = "https://instagram.com/" ; }
                    { title = "Twitter"; url = "https://twitter.com/" ; }
                  ];
                }
                {
                  title = "Forums";
                  color = "\${GRUVBOX_ORANGE}";
                  links = [
                    { title = "NixOS Discourse"; url = "https://discourse.nixos.org/" ; }
                  ];
                }
                {
                  title = "Finance";
                  color = "\${GRUVBOX_BLUE}";
                  links = [
                    { title = "Sofi"; url = "https://login.sofi.com/" ; }
                    { title = "Chase"; url = "https://chase.com/" ; }
                    { title = "Discover"; url = "https://www.discover.com/" ; }
                    { title = "Wells Fargo"; url = "https://wellsfargo.com/" ; }
                  ];
                }
              ];
            }
            {
              type = "bookmarks";
              title = "idx";
              groups = [
                {
                  title = "Personal";
                  color = "\${GRUVBOX_RED}";
                  links = [
                    { title = "recipes"; url = "https://github.com/cartwatson/idx/tree/main/personal/recipes" ; }
                    { title = "maintenance"; url = "https://github.com/cartwatson/idx/tree/main/personal/maintenance" ; }
                  ];
                }
                {
                  title = "Liked Articles";
                  color = "\${GRUVBOX_BLUE}";
                  links = [
                    { title = "HN - doing hard things"; url = "https://news.ycombinator.com/item?id=44560943" ; }
                    { title = "HN - find your people"; url = "https://news.ycombinator.com/item?id=44074017" ; }
                    { title = "Advice that actually worked for me"; url = "https://nabeelqu.substack.com/p/advice?r=hheyu&selection=f0b1192c-03c6-4fc0-97a8-39476c2b3157&utm_campaign=post-share-selection&utm_medium=web&triedRedirect=true#:~:text=Get%20in%20the%20habit%20of%20Fermi%20estimation%2C%20looking%20up%20key%20quantities%2C%20and%20using%20upper%20and%20lower%20bounds" ; }
                    { title = "Thoughts on thinking"; url = "https://dcurt.is/thinking" ; }
                    { title = "The Promised LAN"; url = "https://notes.pault.ag/tpl/" ; }
                  ];
                }
              ];
            }
          ];
        }
      ];
    }
    {
      size = "full";
      widgets = [
        {
          type = "group";
          widgets = [
            {
              type = "hacker-news";
            }
            {
              type = "reddit";
              subreddit = "nixos";
              "show-thumbnails" = false;
              "sort-by" = "top";
              "top-period" = "day";
            }
            {
              type = "reddit";
              subreddit = "selfhosted";
              "show-thumbnails" = false;
              "sort-by" = "top";
              "top-period" = "day";
            }
            {
              type = "reddit";
              subreddit = "crmo";
              "show-thumbnails" = false;
              "sort-by" = "top";
              "top-period" = "week";
            }
            {
              type = "rss";
              title = "RSS";
              style = "vertical-list";
              feeds = [
                {
                  url = "https://selfh.st/rss";
                  title = "selfh.st";
                }
              ];
            }
          ];
        }
        {
          type = "split-column";
          widgets = [
            {
              type = "videos";
              title = "CS + Math";
              style = "vertical-list";
              "collapse-after-rows" = 2;
              limit = 5;
              channels = [
                "UCYO_jab_esuFRV4b17AJtAw"  # 3blue1brown
                "UCsBjURrPoezykLs9EqgamOA"  # Fireship
                "UCUMwY9iS8oMyWDYIe6_RmoA"  # NoBoilerplate
                "UC6biysICWOJ-C3P4Tyeggzg"  # LowLevelLearning
                "UC5--wS0Ljbin1TjWQX6eafA"  # BigboxSWE
              ];
            }
            {
              type = "videos";
              title = "Gaming";
              style = "vertical-list";
              "collapse-after-rows" = 2;
              limit = 5;
              channels = [
                "UC4rqhyiTs7XyuODcECvuiiQ"  # Scott the Woz
                "UCmm3qhYkdW699stV_28TQpw"  # Scotts Stash
                "UCsvn_Po0SmunchJYOWpOxMg"  # Dunkey
                "UC0VVYtw21rg2cokUystu2Dw"  # Smallant
              ];
            }
            {
              type = "videos";
              title = "Homelab";
              style = "vertical-list";
              "collapse-after-rows" = 2;
              limit = 5;
              channels = [
                "UCgdTVe88YVSrOZ9qKumhULQ"  # Hardware Haven
                "UCR-DXc1voovS8nhAvccRZhg"  # Jeff Geerling
                "UCsnGwSIHyoYN0kiINAGUKxg"  # Wolfgang
              ];
            }
            {
              type = "videos";
              title = "Misc";
              style = "vertical-list";
              "collapse-after-rows" = 2;
              limit = 5;
              channels = [
                "UC_mmaVYaFmlfdxuKb6U69Yw"  # speeed
                "UCtHaxi4GTYDpJgMSGy7AeSw"  # Micheal Reeves
                "UCUW49KGPezggFi0PGyDvcvg"  # Zack Friedman
              ];
            }
          ];
        }
      ];
    }
    {
      size = "small";
      widgets = [
        {
          type = "weather";
          location = { _secret = "\${LOCATION}"; };
          units = "imperial";
          "hour-format" = "24h";
        }
        {
          type = "search";
          title = "Wikipedia Search";
          "new-tab" = true;
          "search-engine" = "https://en.wikipedia.org/w/index.php?search={QUERY}";
          bangs = [
            { title = "Google"; shortcut = "!g"; url = "https://www.google.com/search?q={QUERY}" ; }
            { title = "YouTube"; shortcut = "!yt"; url = "https://www.youtube.com/results?search_query={QUERY}" ; }
            { title = "nixpkgs"; shortcut = "!n"; url = "https://search.nixos.org/packages?sort=relevance&query={QUERY}" ; }
            { title = "nixopts"; shortcut = "!no"; url = "https://search.nixos.org/options?sort=relevance&query={QUERY}" ; }
          ];
        }
        {
          type = "releases";
          cache = "1d";
          token = { _secret = "\${GITHUB_READONLY_TOKEN}"; };
          repositories = [
            "helix-editor/helix"
            "ifd3f/caligula"
          ];
        }
        {
          type = "releases";
          title = "3DS releases";
          cache = "1d";
          token = { _secret = "\${GITHUB_READONLY_TOKEN}"; };
          repositories = [
            "DS-Homebrew/nds-bootstrap"
            "LumaTeam/Luma3DS"
            "mgba-emu/mgba"
            "mtheall/ftpd"
            "zoeyjodon/moonlight-N3DS"
            "astronautlevel2/Anemone3DS"
            "Universal-Team/Universal-Updater"
            "d0k3/GodMode9"
          ];
        }
      ];
    }
  ];
}

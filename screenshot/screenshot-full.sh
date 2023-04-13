import -window root /tmp/screenshot.png
xclip -selection clipboard -t image/png -i /tmp/screenshot.png
rm /tmp/screenshot.png

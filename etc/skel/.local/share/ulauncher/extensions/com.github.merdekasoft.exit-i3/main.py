from ulauncher.api.client.Extension import Extension
from ulauncher.api.client.EventListener import EventListener
from ulauncher.api.shared.event import KeywordQueryEvent
from ulauncher.api.shared.item.ExtensionResultItem import ExtensionResultItem
from ulauncher.api.shared.action.RenderResultListAction import RenderResultListAction
from ulauncher.api.shared.action.RunScriptAction import RunScriptAction
from ulauncher.utils.image_loader import icon_theme, Gtk
import os

def get_icon_path(name, size):
    info = icon_theme.lookup_icon(name, size, Gtk.IconLookupFlags.FORCE_SIZE)
    if info is not None:
        return info.get_filename()
    # Fallback icon if not found
    return get_icon_path('system-log-out', size)

def create_item(name, icon, keyword, description, on_enter):
    return ExtensionResultItem(
        name=name,
        description=description,
        icon=get_icon_path(icon, ExtensionResultItem.ICON_SIZE),
        on_enter=RunScriptAction(on_enter, None)
    )

class i3SessionExtension(Extension):
    def __init__(self):
        super(i3SessionExtension, self).__init__()
        if self.is_i3wm():
            self.subscribe(KeywordQueryEvent, KeywordQueryEventListener())
        else:
            self.log_error("This extension is intended for use only in i3wm.")

    def is_i3wm(self):
        return 'i3' in os.getenv('XDG_CURRENT_DESKTOP', '')

items_cache = [
    ('logout', create_item('Logout', 'system-log-out', 'logout', 'Session logout', 'i3-msg exit')),
    ('restart', create_item('Restart', 'system-reboot', 'restart', 'Restart computer', 'systemctl reboot')),
    ('shutdown', create_item('Shutdown', 'system-shutdown', 'shutdown', 'Shutdown computer', 'systemctl poweroff')),
]

class KeywordQueryEventListener(EventListener):
    def on_event(self, event, extension):
        term = (event.get_argument() or '').lower()
        items = [item for keyword, item in items_cache if keyword.startswith(term)]
        return RenderResultListAction(items)

if __name__ == '__main__':
    i3SessionExtension().run()

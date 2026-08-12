.pragma library

function desktopEntryFor(notification, desktopEntries) {
  if (!notification)
    return null;

  if (notification.desktopEntry !== "") {
    for (const entry of desktopEntries) {
      if (entry.id === notification.desktopEntry)
        return entry;
    }
  }

  for (const entry of desktopEntries) {
    if (entry.name.toLowerCase() === notification.appName.toLowerCase())
      return entry;
  }

  return null;
}

function iconFor(notification, desktopEntries) {
  if (!notification)
    return ""

  if (notification.appIcon !== "")
    return notification.appIcon

  const entry = desktopEntryFor(notification, desktopEntries)

  return entry ? entry.icon : ""
}

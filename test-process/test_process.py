import time
import setproctitle

# Set the kernel-visible process name to exactly "test"
setproctitle.setproctitle("test")

# Keep the process alive (harmless)
while True:
    time.sleep(60)

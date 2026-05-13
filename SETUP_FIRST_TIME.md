# First-Time Setup — Moses Deadly Escape Deploy

You only need to do this **once**. After this, `sync-from-work.ps1` and `compress-images.ps1` just work.

---

## Step 1 — Allow PowerShell scripts to run

The "running scripts is disabled" error you saw is Windows' default policy. One command flips it for **your user only** (no admin needed, no system-wide change):

Open **Windows PowerShell** (any window, not as admin) and run:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
```

That's it. Local scripts you write will now run. Scripts downloaded from the internet still get blocked unless you unblock them — which is what we want.

**Verify:**

```powershell
Get-ExecutionPolicy -Scope CurrentUser
```

Should print `RemoteSigned`.

---

## Step 2 — Install pngquant (the image compressor)

`winget` doesn't have pngquant in its default catalog, which is why your command failed. Pick **one** of these instead:

### Option A — Download the official zip (no admin, fastest)

1. Open https://pngquant.org/ in your browser.
2. Scroll to **"Get pngquant"** → download the **Windows** link (zip file, ~200 KB).
3. Extract the zip. Inside you'll find `pngquant.exe`.
4. Copy `pngquant.exe` into this folder:

   ```
   C:\Users\janer\OneDrive\Desktop\moses-deploy\Moses-deadly-escape-Interactive-game\
   ```

The compress script looks here first, so once `pngquant.exe` is in this folder it just works.

### Option B — Chocolatey (if you have it)

```powershell
choco install pngquant
```

### Option C — npm / Node (if you already have Node.js installed)

```powershell
npm install -g imagemin-cli imagemin-pngquant
```

(Then the compress script needs a small tweak — let me know if you go this route.)

---

## Step 3 — Run the workflow

From this folder, in PowerShell:

```powershell
# Copy the latest scene1_palace.html + any new images from the work folder
.\sync-from-work.ps1

# (Recommended) dry-run first — shows what would compress, no writes
.\compress-images.ps1 -DryRun

# Actually compress (creates a one-time backup folder first)
.\compress-images.ps1

# Commit + push to GitHub
git add -A
git commit -m "PM16 v3: kid-friendly lore + audio sweep + image compression"
git push origin main
```

GitHub Pages will rebuild in 30–90 seconds. Test on your phone via the published URL — **never** the local `file:///` path, since that bucket is what your unlocks were getting reset against.

---

## Troubleshooting

**"Cannot be loaded because running scripts is disabled"** — you skipped Step 1. Re-run that one-liner.

**"pngquant.exe not found"** — you skipped Step 2 OR put it in the wrong folder. It must be directly inside `Moses-deadly-escape-Interactive-game\` (not in a subfolder).

**Compression made an image look bad** — copy the original back from `assets\images-original-backup\` (created by the script the first time it runs). The script never touches that backup folder again.

**Want to roll back ALL compression?** Delete `assets\images\`, then rename `assets\images-original-backup\` to `assets\images\`. You're back to the originals.

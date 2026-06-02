# Microsoft Entra ID (Azure AD) Sign-In — Setup Guide

This app can require users to **sign in with their AECOM Microsoft account** (the
same Windows / Office 365 login) instead of a shared passphrase. It uses
[MSAL.js](https://learn.microsoft.com/azure/active-directory/develop/msal-overview)
to delegate authentication to Microsoft — **the app never sees the password.**

By default this is **off** (the app uses the passphrase gate). You turn it on by
filling in two IDs from an Entra app registration.

---

## Important: what this does and doesn't protect

- ✅ It controls **who can sign in and use the app**, and can restrict to your
  organization (tenant) and to specific security groups.
- ⚠️ It is a **Single-Page Application** gate. It **cannot hide the static HTML/JS
  or any data the browser loads** from a determined, signed-out user, because the
  page is public on GitHub Pages.
- 🔒 If the GIS data / photos must be **inaccessible** to unauthorized users, put
  the site behind an **auth proxy** (e.g. Cloudflare Access / Zero Trust) or serve
  it from a backend (e.g. Azure Static Web Apps with Entra). The MSAL gate can be
  layered on top, but the proxy is what truly protects the bytes.

---

## 1. Register the app in Microsoft Entra ID

Ask AECOM IT (or a Global/Application Administrator) to do the following in the
[Entra admin center](https://entra.microsoft.com) → **App registrations → New
registration**:

1. **Name**: e.g. `EIF Visual QA Audit`.
2. **Supported account types**: *Accounts in this organizational directory only*
   (single tenant) — recommended.
3. **Redirect URI**: platform **Single-page application (SPA)**, value = the exact
   URL where this app is served, e.g.
   `https://altezza938.github.io/eif/`
   (include the trailing slash; add every URL you use, e.g. a custom domain).
4. Click **Register**.

From the app's **Overview** page, copy:
- **Application (client) ID**
- **Directory (tenant) ID**

> No client secret is needed — SPAs use PKCE, which MSAL.js handles automatically.

## 2. Configure the app

In `index.html`, find the `AUTH` block and fill in the IDs:

```js
const AUTH = {
    clientId: "00000000-0000-0000-0000-000000000000", // Application (client) ID
    tenantId: "11111111-1111-1111-1111-111111111111", // Directory (tenant) ID
    allowedGroupIds: [],                               // optional, see step 4
    msalCdn: "https://alcdn.msauth.net/browser/2.38.3/js/msal-browser.min.js"
};
```

Save, commit, and deploy. The gate will now show **“Sign in with Microsoft.”**
Leaving `clientId` empty reverts to the passphrase gate.

## 3. (Optional) Restrict to specific security groups

1. In the app registration → **Token configuration → Add groups claim**, choose
   **Security groups** for **ID** tokens.
2. Put the allowed **group object IDs** in `allowedGroupIds`, e.g.:
   ```js
   allowedGroupIds: ["aaaaaaaa-1111-2222-3333-444444444444"]
   ```
Users not in at least one listed group are signed in but **not** admitted.

> If a user is in a very large number of groups, Entra may emit a group
> *overage* claim instead of the list; group checks then need a Graph call.
> For most teams the direct claim is sufficient.

## 4. Notes & troubleshooting

- **Offline build**: SSO needs network access to Microsoft, so the offline
  edition automatically **falls back to the passphrase gate** if MSAL can't load.
- **Redirect URI mismatch (AADSTS50011)**: the SPA redirect URI in Entra must
  match the page URL exactly (scheme, host, path, trailing slash).
- **Sign out**: clears `sessionStorage`; closing the tab also ends the session
  (cache is `sessionStorage`).
- **Library version**: pinned via `AUTH.msalCdn`; bump as needed.

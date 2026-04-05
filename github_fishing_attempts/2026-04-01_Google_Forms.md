## Incident summary
- **Title:** Google-share redirect → fumigacionesdeaguascalientes[.]com (2026-04-01)  
- **Detection date:** 2026-04-01  
- **Summary:** Tagged GitHub users received a recruiting message that eventually redirected via Google share URLs to fumigacionesdeaguascalientes[.]com, which hosted obfuscated JS that collected client fingerprinting data and silently submitted it.

## Indicators & metadata
- **Redirect chain:**  
  - hxxps[:]//share[.]google/GVTYMEMANZWqTptr2  
  - hxxps[:]//www.google[.]com/share.google?q=GVTYMEMANZWqTptr2  
  - hxxps[:]//fumigacionesdeaguascalientes[.]com/recoil/temporality?_r=0de9399d
- **Domain(s):** fumigacionesdeaguascalientes[.]com  
- **SHA256 (raw saved file):** e19212797c7244fabd38f4505aef6952b6fa1fa70b66eb853b5d1b34490c4d24  

## Technical analysis
### What the page does
- Loads heavily obfuscated JavaScript.  
- Collects data: timestamp, Intl locale, navigator platform/userAgent attributes, iframe origin, screen/viewport/DOM-related values.  
- Creates a hidden form and an input containing a JSON payload with those fields, then auto-submits the form to an endpoint.

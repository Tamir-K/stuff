## Incident summary
- **Title:** Google-share redirect → ebookoficial[.]com[.]br (2026-03-25)  
- **Detection date:** 2026-03-25  
- **Summary:** Tagged GitHub users received a security advisory that eventually redirected via Google share URLs to ebookoficial[.]com[.]br.

## Indicators & metadata
- **Redirect chain:**  
  - hxxps[:]//share[.]google/N3NwdcmyaYu9kwZ6D
  - hxxps[:]//www[.]google[.]com/share[.]google?q=N3NwdcmyaYu9kwZ6D
  - hxxps[:]//ebookoficial[.]com[.]br/postamble/synodic?_r=0e47e2ae
- **Domain(s):** ebookoficial[.]com[.]br
- **SHA256 (raw saved file):** e22c429638cd1ebeb5113a500fbaa9a34d7fc775b93f3f0e3d65244bcd64c00c  

## Technical analysis
### What the page does
- Loads heavily obfuscated JavaScript.  

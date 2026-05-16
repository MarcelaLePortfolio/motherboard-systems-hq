
# Phase 723 Test Visual Artifact Sample

## Purpose

Use this sample content only for controlled local testing of the Phase 723 visual artifact marker path.

## Sample Artifact Content

# Test Visual Artifact

## Summary

This artifact should render a sanitized visual block above the semantic fallback when previewed.

<!-- visual-artifact:start -->

<div style="border:1px solid rgba(45,212,191,.45);border-radius:18px;padding:18px;background:linear-gradient(135deg,rgba(20,184,166,.22),rgba(30,64,175,.22));">

  <h2 style="margin:0 0 10px 0;font-size:22px;">Phase 723 Visual Artifact</h2>

  <p style="margin:0;font-size:14px;line-height:1.6;">This is a controlled embedded visual block rendered from explicit artifact markers.</p>

  <div style="display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:10px;margin-top:14px;">

    <div style="border:1px solid rgba(148,163,184,.28);border-radius:14px;padding:12px;">Detected</div>

    <div style="border:1px solid rgba(148,163,184,.28);border-radius:14px;padding:12px;">Sanitized</div>

    <div style="border:1px solid rgba(148,163,184,.28);border-radius:14px;padding:12px;">Rendered</div>

  </div>

</div>

<!-- visual-artifact:end -->

## Outcome

If Phase 723 activation works correctly, this sample produces one Visual Artifact block and still preserves semantic fallback content.

## Next Steps

Validate browser behavior before expanding the visual artifact contract.


# Error Messages

- [QDE_004_013: Detected wrapping filament; please check the filament](#qde_004_013)

<a name="qde_004_013"></a>
## QDE_004_013: "Detected wrapping filament; please check the filament"

This message means the printer tried to pull filament back from the toolhead and could not move it as expected.

One common case is at the end of a print when the remaining filament is already past the Qidi Box extruder, but has not reached the buffer yet. In that situation, the printer tries to retract filament from the toolhead, but the Box can no longer grab the filament end. The printer may report `QDE_004_013` even though nothing is actually wrapped.

This may appear as an `Info` message instead of an error.

If this happens in that end-of-print situation, check the filament path, remove the short remaining piece if needed, and load fresh filament.

If it appears during normal printing, treat it as a real feed problem and inspect the spool, buffer, and filament path for tangles, snags, or excess drag.

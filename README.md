# Find-that-reg-key
Make a change in Windows and see which registry key changes.

Making any change in Windows will change a registry key (sometimes multiples) as well. If you need to see what registry key is associated with a change, perhaps because you need to deploy that change via GPO to your organization, this is the tool for you.

This will take a snapshot of your registry (HKCU), pause while you make any changes, then take a second snapshot and compare the two to show all differences.

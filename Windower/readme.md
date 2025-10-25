# Windower (Pre-Update)
This is a working version of Windower for FFXI on EdenXI, pre-updates.
If allowed to update, Windower will break certain addons such as Debuffed.

# To prevent Windower from updating ->
First roll back your Windower version by downloading my Windower release and overwriting your Windower folder. 
(recommended to backup your Windower folder before overwriting it. I removed addons/plugins and other settings, so it won't overwrite those things)

Now before launching the game -
1. Open the start menu and search "Firewall", select Windows Defender Firewall
2. Go to Advanced settings, this will open your rules window
3. Select Outbound Rules
4. Select New Rule...
5. Select Program > Next
6. This Program Path > Browse to your Windower folder and select Windower.exe > Next
7. Click "Block the connection" > Next
8. Select all 3 boxes, Domain - Private - Public > Next
9. Name it "EdenXI Windower Update Block" > Finish

Now you can safely launch the game, your addons/plugins should be working now, and you don't have to worry about Windower update breaking it again. Enjoy!

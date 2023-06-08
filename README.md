# Radio

Broadcast your currently playing song in [Doppler](https://brushedtype.co/doppler/) to [Discord](https://discord.com/) via Rich Presence.

<details>
  <summary>Example</summary>
  
  <img src="Documentation/example.png">
</details>

## Installing

You can either download one of the [releases](https://github.com/KyleErhabor/Radio/releases) or build from source in Xcode.

## Limitations

### Artwork

Discord uses Activity Asset Images for images displayed in Rich Presence. These must either be URLs to images on the web or IDs for asset images uploaded to the Developer Portal. This is troublesome, as album artwork in Doppler is image data and does not correspond to any URL. To circumvent this limitation, Radio broadcasts an ID associated with the song album, where the album artist and album name are separated by a space and normalized. For example, "Rocket" from Susumu Hirasawa's error CD album is broadcasted as `susumu_hirasawa_error_cd`. With this composition, an image associated with an album can be uploaded to the Developer Portal.
1. Go to the [Developer Portal](https://discord.com/developers/applications)
2. Click the "New Application" button to create a new application for yourself (e.g. call it Radio)
3. On the General Information tab, copy the Application ID and replace the default used in Radio with it
4. Click on Rich Presence > Art Assets and use the "Add Image(s)" button to add the following:
    - The Doppler icon (in `Documentation/Doppler.png`)
    - The album artwork image files named to match their IDs
5. Enable "Display Artwork" in Radio for it to send IDs to Discord. With that, you should start seeing album artwork

If you use [Meta for Mac][meta], you can follow this process to export your album artwork to files.
1. Import all your files
2. From the menu bar, go to Edit > Artwork > Export...
2. Export all the artwork with the following pattern: `albumArtist% %album` 

#### Normalization

The normalization Discord applies to file names differs from Radio's (though, it's close). This will most likely occur when you have an album or album artist name that's not in English. If it happens, please [create an issue](https://github.com/KyleErhabor/Radio/issues/new) about it. 

#### Sizes

Discord requires asset images to be at least 512x512. This may be annoying if you use [Meta for Mac][meta], as the default is 500x500. 

[meta]: https://www.nightbirdsevolve.com/meta/

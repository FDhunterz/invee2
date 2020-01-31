// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:video_player/video_player.dart';

class AmbilGambar extends StatefulWidget {
  final File images;
  AmbilGambar({Key key, this.title, this.images}) : super(key: key);

  final String title;

  @override
  _AmbilGambarState createState() => _AmbilGambarState();
}

class _AmbilGambarState extends State<AmbilGambar> {
  File _imageFile;
  dynamic _pickImageError;
  bool isVideo = false;
  // VideoPlayerController _controller;
  String _retrieveDataError;

  void _onImageButtonPressed(ImageSource source) async {
    // if (_controller != null) {
    //   await _controller.setVolume(0.0);
    // }
    if (isVideo) {
      // final File file = await ImagePicker.pickVideo(source: source);
      // await _playVideo(file);
    } else {
      try {
        _imageFile = await ImagePicker.pickImage(source: source);
        setState(() {});
      } catch (e) {
        _pickImageError = e;
      }
    }
  }

  Future<Null> _cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
      sourcePath: _imageFile.path,
      aspectRatioPresets: Platform.isAndroid
          ? [
              CropAspectRatioPreset.square,
              // CropAspectRatioPreset.ratio3x2,
              // CropAspectRatioPreset.original,
              // CropAspectRatioPreset.ratio4x3,
              // CropAspectRatioPreset.ratio16x9
            ]
          : [
              // CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              // CropAspectRatioPreset.ratio3x2,
              // CropAspectRatioPreset.ratio4x3,
              // CropAspectRatioPreset.ratio5x3,
              // CropAspectRatioPreset.ratio5x4,
              // CropAspectRatioPreset.ratio7x5,
              // CropAspectRatioPreset.ratio16x9
            ],
      androidUiSettings: AndroidUiSettings(
        toolbarTitle: 'Crop Gambar',
        toolbarColor: Colors.green,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.square,
        lockAspectRatio: true,
      ),
    );
    if (croppedFile != null) {
      setState(() {
        _imageFile = croppedFile;
      });
    }
  }

  @override
  void initState() {
    _imageFile = widget.images != null ? widget.images : null;

    super.initState();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _previewImage() {
    final Text retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_imageFile != null) {
      return Image.file(_imageFile);
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    } else {
      return const Text(
        'You have not yet picked an image.',
        textAlign: TextAlign.center,
      );
    }
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await ImagePicker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      if (response.type == RetrieveType.video) {
        isVideo = true;
        // await _playVideo(response.file);
      } else {
        isVideo = false;
        setState(() {
          _imageFile = response.file;
        });
      }
    } else {
      _retrieveDataError = response.exception.code;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Platform.isAndroid
            ? FutureBuilder<void>(
                future: retrieveLostData(),
                builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return const Text(
                        'You have not yet picked an image.',
                        textAlign: TextAlign.center,
                      );
                    case ConnectionState.done:
                      return _previewImage();
                    default:
                      if (snapshot.hasError) {
                        return Text(
                          'Pick image/video error: ${snapshot.error}}',
                          textAlign: TextAlign.center,
                        );
                      } else {
                        return const Text(
                          'You have not yet picked an image.',
                          textAlign: TextAlign.center,
                        );
                      }
                  }
                },
              )
            : _previewImage(),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          _imageFile != null
              ? Container(
                  padding: EdgeInsets.only(top: 16.0),
                  child: FloatingActionButton(
                    tooltip: 'Crop Gambar',
                    child: Icon(Icons.crop),
                    onPressed: () {
                      _cropImage();
                    },
                  ),
                )
              : SizedBox(
                  width: 0.0,
                  height: 0.0,
                ),
          Container(
            padding: EdgeInsets.only(top: 16.0),
            child: FloatingActionButton(
              onPressed: () {
                isVideo = false;
                _onImageButtonPressed(ImageSource.gallery);
              },
              heroTag: 'image0',
              tooltip: 'Pick Image from gallery',
              child: const Icon(Icons.photo_library),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: FloatingActionButton(
              onPressed: () {
                isVideo = false;
                _onImageButtonPressed(ImageSource.camera);
              },
              heroTag: 'image1',
              tooltip: 'Take a Photo',
              child: const Icon(Icons.camera_alt),
            ),
          ),
          _imageFile != null
              ? Container(
                  padding: EdgeInsets.only(top: 16.0),
                  child: FloatingActionButton(
                    onPressed: () {
                      Navigator.pop(context, _imageFile);
                    },
                    child: Icon(Icons.check),
                    tooltip: 'Simpan',
                  ),
                )
              : SizedBox(
                  width: 0.0,
                  height: 0.0,
                ),
        ],
      ),
    );
  }

  Text _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }
}

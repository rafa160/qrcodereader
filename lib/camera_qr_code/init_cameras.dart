
import 'package:camera/camera.dart';

class InitCamerasAvailable {
  static List<CameraDescription> cameras = [];

  static Future<List<CameraDescription>> returnCameras() async {
    cameras = await availableCameras();
    if(cameras.isNotEmpty) {
      return cameras;
    }
    return [];
  }

}
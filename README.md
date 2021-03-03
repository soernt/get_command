# get_command

[![pub package](https://img.shields.io/pub/v/get_command.svg)](https://pub.dartlang.org/packages/get_command)

This library helps providing feedback to the user while executing a controller function.
It is intended to be used with the [Get](https://pub.dev/packages/get) library. 

Let's create an example to showcase the usage:

1. Create a controller with an async function 'longRunningTask':

``` 
import 'package:get/get.dart';

class HomeController extends GetxController {
  final count = 0.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {}

  Future<void> longRunningTask() async {
    await Future.delayed(Duration(seconds: 1));
    count.value++;
  }
}

```

2. Create a simple view
   
``` 
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HomeView'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() {
              return Text("Current value: ${controller.count}");
            }),
            ElevatedButton(
                child: const Text("Start long running task"),
                onPressed: controller.longRunningTask),
          ],
        ),
      ),
    );
  }
}

```

The problem with this code is that user can tap the button again while the longRunningTask function is currently beening executed.

Let's extend the controller to use a GetCommand:

``` 
import 'dart:async';

import 'package:get/get.dart';
import 'package:get_command/get_command.dart';

class HomeController extends GetxController {
  final count = 0.obs;
  final GetCommand cmdLongRunningTask = GetCommand();

  HomeController() {
    cmdLongRunningTask.commandFunc = _longRunningTask;
  }

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {}

  FutureOr<void> _longRunningTask() async {
    await Future.delayed(Duration(seconds: 1));
    count.value++;
  }
}
```
What changed:
1. A new field ```final GetCommand cmdLongRunningTask = GetCommand();``` has been created.
2. During construction time we set the ```cmdLongRunningTask.commandFunc = _longRunningTask;```. That way we tell the command which function should be executed.



Next we update the HomeView to use the Command:

``` 
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_command_example/app/modules/home/controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HomeView'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() {
              return Text("Current value: ${controller.count}");
            }),
            Obx(() {
              return ElevatedButton(
                onPressed: controller.cmdLongRunningTask.canBeExecuted
                    ? controller.cmdLongRunningTask
                    : null,
                child: controller.cmdLongRunningTask.executing
                    ? Row(mainAxisSize: MainAxisSize.min, children: [
                        const Text('Executing'),
                        const CircularProgressIndicator(),
                      ])
                    : const Text('Call computation'),
              );
            }),
          ],
        ),
      ),
    );
  }
}
```

In this way the button is displayed as disabled during execution and also displays a little animation.
A GetCommand is a callable class, you can simply use:

``` 
controller.cmdLongRunningTask
```

instead of

``` 
controller.cmdLongRunningTask.commandFunc
```


In the case your controller function throws an exception, it will be catched and the errorMessage property has a value of ```catchedException.toString()```.

If you catch any exception within your controller function, you can provide the error message via

``` 
code
```

Rember to call the dispose() function to release any associated resource: That are subscriptions to the state property and the commandFunc and errorMessageProviderFunc will be set to null.

I Hope that Command class is of any help for you. 
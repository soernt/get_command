
``` 
class HomeController extends GetxController {
  final computationResult = 0.obs;
  final GetCommand cmdExecuteComputation = GetCommand();

  int _timesCalled = 41;
  
  HomeController() {
    cmdExecuteComputation.commandFunc = _longRunningComputation;
  }

  @override
  void onClose() {
    cmdExecuteComputation.dispose();
    super.onClose();
  }

  FutureOr<void> _longRunningComputation() async {
    await Future.delayed(Duration(seconds: 1));
    computationResult.value = _timesCalled++;
  }
}
```

``` 
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
            Text('Service Value:'),
            Obx(() {
              return Text(
                '${controller.computationResult}',
                style: TextStyle(fontSize: 20),
              );
            }),
            Obx(() {
              return ElevatedButton(
                onPressed: controller.cmdExecuteComputation.canBeExecuted
                    ? cmdExecuteComputation.exec
                    : null,
                child: controller.cmdExecuteComputation.executing
                    ? Row(mainAxisSize: MainAxisSize.min, children: [
                        const Text('Executing'),
                        CircularProgressIndicator(),
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
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage('Flutter Demo Home Page'),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage(this.title);
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Client? httpClient;
  Web3Client? ethClient;
  int sliderVal = 0;
  final myAddress = '0x98488bD52DD788188aF9E1328460e9d7a9b7FC04';
  bool data = false;
  var myData1;
  var myData2;
  int coinSide = 1;
  int loading = 0;
  bool locked = false;
  int dAmount = 0;
  int result = 0;
  String player1address = "0xF91349BBF78Ee60734906769236E59efB2a25456";
  String player2address = "0xf4a1b61a144592106824Fa29dAc86AD739172657";
  bool winData = false;

  @override
  void initState() {
    super.initState();
    httpClient = Client();
    ethClient = Web3Client('http://10.0.2.2:7545', httpClient!);

    getBalance(myAddress);
  }

  Future<DeployedContract> loadPlayer1() async {
    String abi_wallet = await rootBundle.loadString('assets/abi.json');

    DeployedContract player1 = DeployedContract(
        ContractAbi.fromJson(abi_wallet, "PKCoin"),
        EthereumAddress.fromHex(player1address));

    return player1;
  }

  Future<DeployedContract> loadPlayer2() async {
    String abi_wallet = await rootBundle.loadString('assets/abi.json');

    DeployedContract player2 = DeployedContract(
        ContractAbi.fromJson(abi_wallet, "PKCoin"),
        EthereumAddress.fromHex(player2address));

    return player2;
  }

  Future<DeployedContract> loadGame() async {
    String abi_game = await rootBundle.loadString('assets/abi_game.json');
    String gameAddress = "0x4dF65f3a1fB93729DB833E4f37fb88c5760ca768";

    DeployedContract game = DeployedContract(
        ContractAbi.fromJson(abi_game, "Game"),
        EthereumAddress.fromHex(gameAddress));

    return game;
  }

  Future<List<dynamic>> query_player1(
      String functionName, List<dynamic> args) async {
    final player1 = await loadPlayer1();
    final ethFunction_player1 = player1.function(functionName);

    final result = await ethClient?.call(
        contract: player1, function: ethFunction_player1, params: args);
    return result!;
  }

  Future<List<dynamic>> query_player2(
      String functionName, List<dynamic> args) async {
    final player2 = await loadPlayer2();
    final ethFunction_player2 = player2.function(functionName);

    final result = await ethClient?.call(
        contract: player2, function: ethFunction_player2, params: args);
    return result!;
  }

  Future<List<dynamic>> query_game(
      String functionName, List<dynamic> args) async {
    final game = await loadGame();
    final ethFunction_game = game.function(functionName);

    final result = await ethClient?.call(
        contract: game, function: ethFunction_game, params: args);
    return result!;
  }

  Future<void> getBalance(String targetAddress) async {
    List<dynamic> result1 = await query_player1('getBalance', []);
    myData1 = result1[0];
    List<dynamic> result2 = await query_player2('getBalance', []);
    myData2 = result2[0];
    data = true;
    setState(() {});
  }

  Future<String> submit1(String functionName, List<dynamic> args) async {
    EthPrivateKey credentials = EthPrivateKey.fromHex(
        '2215f57dad676b88106ed8c9b90261bdf1f8a4c36284d5415e11832e3a22077b');

    DeployedContract player1 = await loadPlayer1();
    final ethFunction = player1.function(functionName);

    final result = await ethClient?.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: player1,
        function: ethFunction,
        parameters: args,
      ),
      chainId: 1337,
    );
    return result!;
  }

  Future<String> submit2(String functionName, List<dynamic> args) async {
    EthPrivateKey credentials = EthPrivateKey.fromHex(
        '2215f57dad676b88106ed8c9b90261bdf1f8a4c36284d5415e11832e3a22077b');

    DeployedContract player2 = await loadPlayer2();

    final ethFunction = player2.function(functionName);

    final result = await ethClient?.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: player2,
        function: ethFunction,
        parameters: args,
      ),
      chainId: 1337,
    );
    return result!;
  }

  Future<String> submit3(String functionName, List<dynamic> args) async {
    EthPrivateKey credentials = EthPrivateKey.fromHex(
        '2215f57dad676b88106ed8c9b90261bdf1f8a4c36284d5415e11832e3a22077b');
    DeployedContract game = await loadGame();
    final ethFunction = game.function(functionName);
    final result = await ethClient?.sendTransaction(
        credentials,
        Transaction.callContract(
            contract: game, function: ethFunction, parameters: args),
        chainId: 1337);
    return result!;
  }

  Future<String> sendCoin1() async {
    var bigAmount = BigInt.from(sliderVal);
    dAmount = sliderVal;
    var response = await submit1("deposit", [bigAmount]);

    return response;
  }

  Future<String> sendCoin2() async {
    var bigAmount = BigInt.from(sliderVal);
    dAmount = sliderVal;
    var response = await submit2("deposit", [bigAmount]);

    return response;
  }

  Future<String> init_game(int f) async {
    var response = await submit3("init", [
      EthereumAddress.fromHex(player1address),
      EthereumAddress.fromHex(player2address),
      BigInt.from(f),
    ]);
    var response2 = await submit3("wins", []);
    return response2;
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Colors.black, Colors.indigo]),
            ),
          ),
          title: Text(
            "Greedy Gamble",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('images/gif1.gif'), fit: BoxFit.cover),
          ),
          padding: EdgeInsets.fromLTRB(
              width / 10.27, height / 56.9, width / 10.27, height / 56.9),
          child: Center(
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: width / 8.22,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: width / 8.65,
                            backgroundImage: AssetImage('images/art.jpeg'),
                          ),
                        ),
                        SizedBox(height: height / 34.15),
                        Text(
                          'Pranjal',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: width / 20.55,
                              fontFamily: "Inter"),
                        ),
                        data
                            ? Text(
                                "${myData1.toString()} eth",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: width / 13.7,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Inter"),
                              )
                            : CircularProgressIndicator(),
                        SizedBox(height: height / 68.3),
                        ElevatedButton(
                          onPressed: () {
                            sendCoin1();
                            setState(() {
                              locked = true;
                              winData = false;
                            });
                          },
                          child: Text(
                            'Deposit',
                            style: TextStyle(
                                fontFamily: "Inter", fontSize: width / 25.68),
                          ),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Color(0xFF2945D9)),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                side: BorderSide(
                                  color: Color(0xFF2945D9),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          'v/s',
                          textScaleFactor: 1,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: width / 10.275,
                              fontFamily: 'Manuale'),
                        ),
                        SizedBox(height: height / 5.2),
                        ElevatedButton(
                          onPressed: () {
                            getBalance(myAddress);
                          },
                          child: Icon(Icons.refresh, color: Colors.white),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Color(0xFF10BB55)),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                side: BorderSide(
                                  color: Color(0xFF10BB55),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        CircleAvatar(
                          radius: width / 8.22,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: width / 8.65,
                            backgroundImage: AssetImage('images/back.jpg'),
                          ),
                        ),
                        SizedBox(height: height / 34.15),
                        Text(
                          'Aryan',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: width / 20.55,
                              fontFamily: 'Inter'),
                        ),
                        data
                            ? Text(
                                "${myData2.toString()} eth",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: width / 13.7,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Inter'),
                              )
                            : CircularProgressIndicator(),
                        SizedBox(height: height / 68.3),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              locked = true;
                              winData = false;
                            });
                            sendCoin2();
                          },
                          child: Text(
                            'Deposit',
                            style: TextStyle(
                                fontFamily: 'Inter', fontSize: width / 25.68),
                          ),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Color(0xFF2945D9)),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                side: BorderSide(
                                  color: Color(0xFF2945D9),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: height / 34.15),
                Container(
                  padding: EdgeInsets.all(height / 28.45),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.00),
                      color: Colors.white),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        locked
                            ? "${dAmount.toString()} Goerliether"
                            : "${sliderVal.toString()} Goerliether",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: width / 25.68,
                            fontFamily: 'Inter'),
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Color(0xFF2945D9),
                            thumbShape:
                                RoundSliderThumbShape(enabledThumbRadius: 8.00),
                            thumbColor: Color(0xFF2945D9),
                            overlayColor: Colors.blue,
                            overlayShape: RoundSliderOverlayShape(
                                overlayRadius: width / 34.25)),
                        child: Slider(
                            min: 0,
                            max: 100,
                            inactiveColor: Color(0xFF2945D9),
                            value: locked
                                ? dAmount.toDouble()
                                : sliderVal.toDouble(),
                            onChanged: (double newValue) {
                              locked
                                  ? () {}
                                  : setState(() {
                                      sliderVal = newValue.round();
                                    });
                            }),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: height / 27.32, bottom: 0),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          loading == 0
                              ? CircleAvatar(
                                  radius: width / 6,
                                  backgroundImage:
                                      AssetImage('images/c$coinSide.png'),
                                  backgroundColor: Colors.yellow,
                                )
                              : Container(
                                  height: width / 3.02,
                                  width: width / 3.02,
                                  padding: EdgeInsets.all(width / 12.10),
                                  child: CircularProgressIndicator(),
                                ),
                          SizedBox(height: height / 136.6),
                          ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                loading = 1;
                              });

                              await Timer(Duration(seconds: 3), () {
                                setState(() {
                                  loading = 0;
                                  coinSide = Random().nextInt(2) + 1;
                                  init_game(coinSide);
                                  locked = false;
                                  sliderVal = 0;
                                  result = 1;
                                  winData = true;
                                });
                              });
                            },
                            child: Text(
                              '  Flip  ',
                              style: TextStyle(
                                  fontFamily: 'Inter', fontSize: width / 18.68),
                            ),
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Color(0xFF2945D9)),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  side: BorderSide(
                                    color: Color(0xFF2945D9),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: width / 10.81),
                      result == 0
                          ? SizedBox()
                          : winData
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'RESULT',
                                      textScaleFactor: 1,
                                      style: TextStyle(
                                          fontSize: width / 15.8,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontFamily: 'Manuale'),
                                    ),
                                    Text(
                                      coinSide == 1
                                          ? 'Pranjal Won'
                                          : 'Aryan Won',
                                      textScaleFactor: 1,
                                      style: TextStyle(
                                          fontSize: width / 15.8,
                                          color: Colors.white,
                                          fontFamily: 'Manuale'),
                                    ),
                                    SizedBox(height: height / 34.15),
                                    Text(
                                      'Balance Won',
                                      textScaleFactor: 1,
                                      style: TextStyle(
                                          fontSize: width / 20.55,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Manuale'),
                                    ),
                                    Text(
                                      "${(2 * dAmount).toString()} eth",
                                      textScaleFactor: 1,
                                      style: TextStyle(
                                          fontSize: width / 10.27,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Manuale'),
                                    ),
                                  ],
                                )
                              : SizedBox()
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

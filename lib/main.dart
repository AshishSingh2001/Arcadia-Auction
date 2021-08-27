import 'package:arcadia/provider/announcements.dart';
import 'package:arcadia/provider/auth.dart';
import 'package:arcadia/provider/matches.dart';
import 'package:arcadia/provider/players.dart';
import 'package:arcadia/provider/teams.dart';
import 'package:arcadia/screens/Auction/auction_details.dart';
import 'package:arcadia/screens/Auction/auction_overview.dart';
import 'package:arcadia/screens/Auction/auction_player.dart';
import 'package:arcadia/screens/Player/PlayerScreens/home_screen.dart';
import 'package:arcadia/screens/Player/PlayerScreens/player_dashboard.dart';
import 'package:arcadia/screens/Player/PlayerScreens/rules_pdf_viewer.dart';
import 'package:arcadia/screens/Player/PlayerScreens/schedule_screen.dart';
import 'package:arcadia/screens/Player/PlayerScreens/team_details.dart';
import 'package:arcadia/screens/onBoardingScreen.dart';
import 'package:arcadia/screens/splash_screen.dart';
import 'package:arcadia/screens/wrapper.dart';
import 'package:arcadia/screens/Auction/auction_home.dart';
import 'package:arcadia/screens/signin_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'constants/app_theme.dart';
import 'screens/Auction/auction_resell_player.dart';
import 'screens/Player/PlayerScreens/player_profile_screen.dart';
import 'screens/Player/player_form.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIOverlays(
      [SystemUiOverlay.bottom, SystemUiOverlay.top]);
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Init.instance.initialize(),
      builder: (context, AsyncSnapshot snapshot) {
        // Show splash screen while waiting for app resources to load:
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(home: SplashScree());
        } else {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider<Players>(
                create: (_) => Players(),
              ),
              ChangeNotifierProvider<Matches>(
                create: (_) => Matches(),
              ),
              ChangeNotifierProvider<Teams>(
                create: (_) => Teams(),
              ),
              ChangeNotifierProvider<Auth>(
                create: (_) => Auth(),
              ),
              ChangeNotifierProvider<Announcements>(
                create: (_) => Announcements(),
              ),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Arcadia CSGO League',
              theme: ThemeData(
                primaryColor: CustomColors.primaryColor,
                accentColor: CustomColors.secondaryColor,
                textTheme:
                    GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
              ),
              home: getHome(snapshot.data),
              routes: {
                AuctionOverview.routeName: (ctx) => AuctionOverview(),
                AuctionHome.routeName: (ctx) => AuctionHome(),
                AuctionPlayer.routeName: (ctx) => AuctionPlayer(),
                AuctionPlayerResell.routeName: (ctx) => AuctionPlayerResell(),
                AuctionDetails.routeName: (ctx) => AuctionDetails(),
                TeamDetails.routeName: (ctx) => TeamDetails(),
                ScheduleScreen.routeName: (ctx) => ScheduleScreen(),
                PlayerProfileScreen.routeName: (ctx) => PlayerProfileScreen(),
                RulesPdfViewer.routeName: (ctx) => RulesPdfViewer(),
                SignInScreen.routeName: (ctx) => SignInScreen(),
              },
            ),
          );
        }
      },
    );
  }

  Widget getHome(int authLevel) {
    switch (authLevel) {
      case -1:
        return OnboardingScreen();
      // break;
      case 0:
        return PlayerForm();
      // break;
      case 1:
        return PlayerDashBoard();
      // break;
      case 2:
        return AuctionOverview();
      // break;
      default:
        return Center(child: Text('Something Went wrong : ((((('));
    }
  }
}

class Init {
  Init._();
  static final instance = Init._();

  Future<int?> initialize() async {
    await Firebase.initializeApp();
    if (!Auth.isAuth) {
      return -1;
    } else {
      Auth.setUid();
      // DocumentSnapshot<Map<String, dynamic>> documentSnapshot;
      var documentSnapshot = await FirebaseFirestore.instance
          .collection('Player')
          .doc(Auth.uid)
          .get();
      if (!documentSnapshot.exists) {
        return 0;
      } else if (!documentSnapshot.data()!['isAdmin']) {
        return 1;
      } else {
        return 2;
      }
    }
  }
}

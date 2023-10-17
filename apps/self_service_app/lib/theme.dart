import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static var selectedPrimaryColor  = Colors.black;
  static final Light = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.light(
          primary: selectedPrimaryColor,
          background: Color(0xFFF8F8F8),
          secondary: Color(0xFF2664FE),
          onPrimary: Colors.white,
          tertiary: Color(0xFF00B43D),
          secondaryContainer: Color(0xFFD0DDFF),
          onBackground: Colors.black,
          error: Colors.red),
      dividerTheme: DividerThemeData().copyWith(color: Colors.grey[300]),
      appBarTheme: const AppBarTheme().copyWith(
        elevation: 0,
        color: Colors.black,
        titleTextStyle: const TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      textTheme: GoogleFonts.ralewayTextTheme().copyWith(
        headlineLarge:
             GoogleFonts.raleway().copyWith(fontSize: 40, fontWeight: FontWeight.bold),
        displayLarge:
            GoogleFonts.raleway().copyWith(fontSize: 30, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.raleway().copyWith(
            fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black),
        displaySmall:
           GoogleFonts.raleway().copyWith(fontSize: 24, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.raleway().copyWith(fontSize: 19, fontWeight: FontWeight.bold),
        titleMedium: GoogleFonts.raleway().copyWith(fontSize: 17),
        titleSmall:GoogleFonts.raleway().copyWith(fontSize: 14, color: Colors.black54),
        bodyLarge: GoogleFonts.raleway().copyWith(fontSize: 19, color: Colors.grey),
        bodyMedium: GoogleFonts.raleway().copyWith(fontSize: 17, color: Colors.grey),
        bodySmall: GoogleFonts.raleway().copyWith(fontSize: 15, color: Colors.grey),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 22),
              side: BorderSide(color: selectedPrimaryColor),
              textStyle: TextStyle(fontSize: 17))),
      filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 22),
              textStyle: TextStyle(fontSize: 17 , fontWeight: FontWeight.bold))),
      textButtonTheme: TextButtonThemeData( 
          style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 22),
              textStyle: TextStyle(fontSize: 19))),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(),
        errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
        hintStyle: const TextStyle(fontWeight: FontWeight.normal),
        // contentPadding: EdgeInsets.symmetric(vertical: 22, horizontal: 26),
        errorStyle: const TextStyle(fontWeight: FontWeight.normal, color: Colors.grey),
        labelStyle: const TextStyle(fontWeight: FontWeight.normal, color: Colors.grey),
        
      ),
      popupMenuTheme: PopupMenuThemeData().copyWith(
       surfaceTintColor: Colors.white,
      ),
      cardTheme: const CardTheme()
          .copyWith(color: Colors.white, surfaceTintColor: Colors.white),
      snackBarTheme: SnackBarThemeData(width: 600 , behavior: SnackBarBehavior.floating)    
      );

  static updatePrimaryColor(Color color){
    selectedPrimaryColor = color;
    var newTheme =  Light.copyWith(colorScheme :  ColorScheme.light(
          primary: selectedPrimaryColor,
          background: Color(0xFFF8F8F8),
          secondary: Colors.black87,
          onPrimary: Colors.white,
          tertiary: Color(0xFF00B43D),
          secondaryContainer: Color(0xFFD0DDFF),
          onBackground: Colors.black, 
          error: Colors.red),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 22),
                side: BorderSide(color: selectedPrimaryColor),
                textStyle: TextStyle(fontSize: 17),
              ),
          ),
          inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(),
        errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: selectedPrimaryColor)),
        hintStyle: const TextStyle(fontWeight: FontWeight.normal),
        // contentPadding: EdgeInsets.symmetric(vertical: 22, horizontal: 26),
        errorStyle: const TextStyle(fontWeight: FontWeight.normal, color: Colors.grey),
        labelStyle: const TextStyle(fontWeight: FontWeight.normal, color: Colors.grey),
        
      ),
        );
    return newTheme; 
  }
}

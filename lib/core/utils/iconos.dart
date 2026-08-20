import 'package:flutter/cupertino.dart';

const iconosDisponibles = [
  'car',
  'fork_knife',
  'airplane',
  'bandage',
  'location',
  'moon',
  'cart',
  'house',
  'sport',
  'book',
  'briefcase',
  'gift',
  'heart',
  'paw',
  'person',
  'calendar',
];

IconData obtenerIcono(String icono) {
  switch (icono) {
    case 'car':
      return CupertinoIcons.car;

    case 'fork_knife':
      return CupertinoIcons.square_grid_2x2;

    case 'airplane':
      return CupertinoIcons.airplane;

    case 'bandage':
      return CupertinoIcons.bandage;

    case 'location':
      return CupertinoIcons.location;

    case 'moon':
      return CupertinoIcons.moon;

    case 'cart':
      return CupertinoIcons.cart;

    case 'house':
      return CupertinoIcons.house;

    case 'sport':
      return CupertinoIcons.sportscourt;

    case 'book':
      return CupertinoIcons.book;

    case 'briefcase':
      return CupertinoIcons.briefcase;

    case 'gift':
      return CupertinoIcons.gift;

    case 'heart':
      return CupertinoIcons.heart;

    case 'paw':
      return CupertinoIcons.paw;

    case 'person':
      return CupertinoIcons.person;

    case 'calendar':
      return CupertinoIcons.calendar;

    default:
      return CupertinoIcons.circle;
  }
}

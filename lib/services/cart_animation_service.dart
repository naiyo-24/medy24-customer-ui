import 'package:flutter/material.dart';
import 'package:add_to_cart_animation/add_to_cart_animation.dart';

class CartAnimationService {
  static final GlobalKey<CartIconKey> cartKey = GlobalKey<CartIconKey>();
  static void Function(GlobalKey)? runAddToCartAnimation;

  static void triggerAnimation(GlobalKey sourceKey) {
    if (runAddToCartAnimation != null) {
      runAddToCartAnimation!(sourceKey);
    }
  }
}

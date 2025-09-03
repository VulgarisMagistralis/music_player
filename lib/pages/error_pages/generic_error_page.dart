import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/pages/error_pages/basic_error_page.dart';

class GenericErrorPage extends BasicErrorPage {
  const GenericErrorPage({super.key, super.message, super.actionWidget, super.showNavigation});
  @override
  ConsumerState<GenericErrorPage> createState() => BasicErrorPageState<GenericErrorPage>();
}

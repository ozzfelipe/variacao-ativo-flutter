import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:variacao_ativo_flutter/src/modules/home/domain/presentention/home/home_event.dart';
import 'package:variacao_ativo_flutter/src/modules/home/domain/presentention/home/home_state.dart';
import 'package:variacao_ativo_flutter/src/modules/home/ui/widgets/line_chart.dart';
import 'package:variacao_ativo_flutter/src/modules/home/ui/widgets/screen_loading.dart';

class MyHomePage extends StatefulWidget {
  final ValueListenable<HomeState> state;
  final void Function(HomeEvent) onEvent;
  const MyHomePage({
    super.key,
    required this.title,
    required this.state,
    required this.onEvent,
  });

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void Function(HomeEvent) get onEvent => widget.onEvent;
  ValueListenable<HomeState> get state => widget.state;

  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: Text(
          widget.title,
          style: TextStyle(color: colorScheme.onPrimary),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: state,
        builder: (_, state, child) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: SafeArea(
                  child: Column(
                    children: [
                      _buildFormField(),
                      const SizedBox(height: 80),
                      if (state.stockIndicatorList == null)
                        const Text('Nenhum ativo selecionado'),
                      if (state.stockIndicatorList != null)
                        CustomLineChart(
                          stockData: state.stockIndicatorList!,
                        )
                    ],
                  ),
                ),
              ),
              if (state.loading) const ScreenLoading()
            ],
          );
        },
      ),
    );
  }

  Widget _buildFormField() {
    return Form(
      key: _formKey,
      child: TextFormField(
        controller: _textEditingController,
        focusNode: _focusNode,
        textCapitalization: TextCapitalization.characters,
        decoration: InputDecoration(
          label: const Text('Busque um ativo'),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          suffixIcon: IconButton(
            onPressed: _onSearch,
            icon: const Icon(Icons.search),
          ),
          counterText: '',
        ),
        onFieldSubmitted: (_) {
          _onSearch();
        },
        validator: (value) {
          if (value!.length <= 4 && value.isNotEmpty) {
            return 'Insira um ativo válido';
          }
          return null;
        },
        inputFormatters: [
          FilteringTextInputFormatter.deny(RegExp(r'[^a-zA-Z0-9]'))
        ],
        maxLength: 6,
      ),
    );
  }

  void _onSearch() {
    if (_formKey.currentState?.validate() ?? false) {
      onEvent(HomeEvent.fetchStockIndicatorsById(_textEditingController.text));
    }
  }
}

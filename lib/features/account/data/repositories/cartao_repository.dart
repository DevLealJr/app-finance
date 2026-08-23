import 'package:finance/features/account/data/models/usuario_model.dart';

class CartaoRepository {
  final List<CartaoModel> _cartoes = [];

  Future<List<CartaoModel>> listarTodos() async {
    return List.unmodifiable(_cartoes);
  }

  Future<void> salvar(CartaoModel cartao) async {
    _cartoes.add(cartao);
  }
}

import 'package:finance/features/transactions/data/models/transacao_model.dart';

class TransacaoRepository {
  final List<TransacaoModel> _transacoes = [];

  Future<List<TransacaoModel>> listarTodas() async {
    return List.unmodifiable(_transacoes);
  }

  Future<void> salvarTodas(List<TransacaoModel> transacoes) async {
    _transacoes.addAll(transacoes);
  }
}

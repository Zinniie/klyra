import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/models/models.dart';
import '../repository/transaction_repository.dart';

// ── Events ─────────────────────────────────────────────────────
abstract class TransactionEvent extends Equatable {
  const TransactionEvent();
  @override List<Object?> get props => [];
}

class TransactionLoadRecent extends TransactionEvent {
  const TransactionLoadRecent({required this.userId});
  final String userId;
  @override List<Object?> get props => [userId];
}

class TransactionReset extends TransactionEvent { const TransactionReset(); }

class TransactionSendMoney extends TransactionEvent {
  const TransactionSendMoney({
    required this.senderId,
    required this.senderName,
    required this.recipientId,
    required this.recipientName,
    required this.recipientPhone,
    required this.amount,
    this.note,
  });
  final String senderId;
  final String senderName;
  final String recipientId;
  final String recipientName;
  final String recipientPhone;
  final double amount;
  final String? note;
  @override List<Object?> get props => [senderId, recipientId, amount];
}

// ── States ─────────────────────────────────────────────────────
abstract class TransactionState extends Equatable {
  const TransactionState();
  @override List<Object?> get props => [];
}

class TransactionInitial extends TransactionState { const TransactionInitial(); }
class TransactionLoading extends TransactionState { const TransactionLoading(); }

class TransactionLoaded extends TransactionState {
  const TransactionLoaded({required this.transactions});
  final List<KlyraTransaction> transactions;
  @override List<Object?> get props => [transactions];
}

class TransactionSuccess extends TransactionState {
  const TransactionSuccess({required this.transaction});
  final KlyraTransaction transaction;
  @override List<Object?> get props => [transaction];
}

class TransactionError extends TransactionState {
  const TransactionError({required this.message});
  final String message;
  @override List<Object?> get props => [message];
}

// ── BLoC ───────────────────────────────────────────────────────
class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  TransactionBloc({required TransactionRepository repository})
      : _repo = repository,
        super(const TransactionInitial()) {
    on<TransactionReset>((_, emit) => emit(const TransactionInitial()));
    on<TransactionLoadRecent>(_onLoadRecent);
    on<TransactionSendMoney>(_onSendMoney);
  }

  final TransactionRepository _repo;

  Future<void> _onLoadRecent(
    TransactionLoadRecent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionLoading());
    try {
      final txs = await _repo.getRecentTransactions(event.userId);
      emit(TransactionLoaded(transactions: txs));
    } catch (e) {
      emit(TransactionError(message: e.toString()));
    }
  }

  Future<void> _onSendMoney(
    TransactionSendMoney event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionLoading());
    try {
      final tx = await _repo.sendMoney(
        senderId:       event.senderId,
        senderName:     event.senderName,
        recipientId:    event.recipientId,
        recipientName:  event.recipientName,
        recipientPhone: event.recipientPhone,
        amount:         event.amount,
        note:           event.note,
      );
      emit(TransactionSuccess(transaction: tx));
    } catch (e) {
      emit(TransactionError(message: e.toString()));
    }
  }
}

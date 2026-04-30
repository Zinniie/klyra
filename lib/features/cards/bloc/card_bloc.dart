import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/models/models.dart';
import '../repository/card_repository.dart';

// ── Events ─────────────────────────────────────────────────────
abstract class CardEvent extends Equatable {
  const CardEvent();
  @override List<Object?> get props => [];
}

class CardReset extends CardEvent { const CardReset(); }

class CardAdd extends CardEvent {
  const CardAdd({required this.userId, required this.card});
  final String   userId;
  final KlyraCard card;
  @override List<Object?> get props => [userId, card.id];
}

class CardLoad extends CardEvent {
  const CardLoad({required this.userId});
  final String userId;
  @override List<Object?> get props => [userId];
}

class CardRemove extends CardEvent {
  const CardRemove({required this.userId, required this.cardId});
  final String userId;
  final String cardId;
  @override List<Object?> get props => [userId, cardId];
}

class CardSetDefault extends CardEvent {
  const CardSetDefault({required this.userId, required this.cardId});
  final String userId;
  final String cardId;
  @override List<Object?> get props => [userId, cardId];
}

// ── States ─────────────────────────────────────────────────────
abstract class CardState extends Equatable {
  const CardState();
  @override List<Object?> get props => [];
}

class CardInitial extends CardState { const CardInitial(); }
class CardLoading extends CardState { const CardLoading(); }

class CardLoaded extends CardState {
  const CardLoaded({required this.cards});
  final List<KlyraCard> cards;
  @override List<Object?> get props => [cards];
}

class CardError extends CardState {
  const CardError({required this.message});
  final String message;
  @override List<Object?> get props => [message];
}

// ── BLoC ───────────────────────────────────────────────────────
class CardBloc extends Bloc<CardEvent, CardState> {
  CardBloc({required CardRepository repository})
      : _repo = repository,
        super(const CardInitial()) {
    on<CardReset>((_, emit) => emit(const CardInitial()));
    on<CardLoad>(_onLoad);
    on<CardAdd>(_onAdd);
    on<CardRemove>(_onRemove);
    on<CardSetDefault>(_onSetDefault);
  }

  final CardRepository _repo;

  Future<void> _onLoad(CardLoad event, Emitter<CardState> emit) async {
    emit(const CardLoading());
    try {
      final cards = await _repo.getCards(event.userId);
      emit(CardLoaded(cards: cards));
    } catch (e) {
      emit(CardError(message: e.toString()));
    }
  }

  Future<void> _onAdd(CardAdd event, Emitter<CardState> emit) async {
    try {
      await _repo.addCard(userId: event.userId, card: event.card);
      add(CardLoad(userId: event.userId));
    } catch (e) {
      emit(CardError(message: e.toString()));
    }
  }

  Future<void> _onRemove(CardRemove event, Emitter<CardState> emit) async {
    try {
      await _repo.removeCard(userId: event.userId, cardId: event.cardId);
      add(CardLoad(userId: event.userId));
    } catch (e) {
      emit(CardError(message: e.toString()));
    }
  }

  Future<void> _onSetDefault(CardSetDefault event, Emitter<CardState> emit) async {
    try {
      await _repo.setDefaultCard(userId: event.userId, cardId: event.cardId);
      add(CardLoad(userId: event.userId));
    } catch (e) {
      emit(CardError(message: e.toString()));
    }
  }
}

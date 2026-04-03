import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/features/whatsapp-hooks/data/repositories/whatsapp_hook_repository_impl.dart';
import 'package:handlerclaw/features/whatsapp-hooks/domain/entities/whatsapp_message_entity.dart';
import 'package:handlerclaw/features/whatsapp-hooks/domain/repositories/whatsapp_hook_repository.dart';

class WhatsappHookState {
  final List<WhatsappMessageEntity> messages;
  final int total;
  final int page;
  final int perPage;
  final bool isLoadingMore;
  final bool hasMore;
  final String? search;
  final String? chatId;
  final WhatsappMessageType? messageType;
  final bool? isFromMe;

  WhatsappHookState({
    required this.messages,
    required this.total,
    required this.page,
    required this.perPage,
    required this.isLoadingMore,
    required this.hasMore,
    this.search,
    this.chatId,
    this.messageType,
    this.isFromMe,
  });

  WhatsappHookState copyWith({
    List<WhatsappMessageEntity>? messages,
    int? total,
    int? page,
    int? perPage,
    bool? isLoadingMore,
    bool? hasMore,
    String? search,
    String? chatId,
    WhatsappMessageType? messageType,
    bool? isFromMe,
    bool clearIsFromMe = false,
  }) {
    return WhatsappHookState(
      messages: messages ?? this.messages,
      total: total ?? this.total,
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      search: search ?? this.search,
      chatId: chatId ?? this.chatId,
      messageType: messageType ?? this.messageType,
      isFromMe: clearIsFromMe ? null : (isFromMe ?? this.isFromMe),
    );
  }
}

class WhatsappHooksController extends AsyncNotifier<WhatsappHookState> {
  Timer? _searchDebounce;

  WhatsappHookRepository get _repository =>
      ref.read(whatsappHookRepositoryProvider);

  @override
  FutureOr<WhatsappHookState> build() async {
    return _fetchMessages();
  }

  void setFilter({
    String? chatId,
    WhatsappMessageType? messageType,
    bool? isFromMe,
    bool clearIsFromMe = false,
  }) async {
    final currentState = state.value;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetchMessages(
        search: currentState?.search,
        chatId: chatId ?? currentState?.chatId,
        messageType: messageType ?? currentState?.messageType,
        isFromMe: clearIsFromMe ? null : (isFromMe ?? currentState?.isFromMe),
      ),
    );
  }

  Future<WhatsappHookState> _fetchMessages({
    int page = 1,
    String? search,
    String? chatId,
    WhatsappMessageType? messageType,
    bool? isFromMe,
  }) async {
    final result = await _repository.getMessages(
      page: page,
      search: search,
      chatId: chatId,
      messageType: messageType,
      isFromMe: isFromMe,
    );

    return WhatsappHookState(
      messages: result.messages,
      total: result.total,
      page: page,
      perPage: 10,
      isLoadingMore: false,
      hasMore: result.messages.length >= 10,
      search: search,
      chatId: chatId,
      messageType: messageType,
      isFromMe: isFromMe,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetchMessages(
        search: state.value?.search,
        chatId: state.value?.chatId,
        messageType: state.value?.messageType,
        isFromMe: state.value?.isFromMe,
      ),
    );
  }

  Future<void> loadMore() async {
    final currentState = state.value;
    if (currentState == null ||
        currentState.isLoadingMore ||
        !currentState.hasMore) {
      return;
    }

    state = AsyncData(currentState.copyWith(isLoadingMore: true));

    try {
      final nextPage = currentState.page + 1;

      final result = await _repository.getMessages(
        page: nextPage,
        search: currentState.search,
        chatId: currentState.chatId,
        messageType: currentState.messageType,
        isFromMe: currentState.isFromMe,
      );

      state = AsyncData(
        currentState.copyWith(
          messages: [...currentState.messages, ...result.messages],
          page: nextPage,
          isLoadingMore: false,
          hasMore: result.messages.length >= currentState.perPage,
          total: result.total,
        ),
      );
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  void setSearch(String? search) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () async {
      final currentState = state.value;
      state = const AsyncLoading();
      state = await AsyncValue.guard(
        () => _fetchMessages(
          search: search,
          chatId: currentState?.chatId,
          messageType: currentState?.messageType,
          isFromMe: currentState?.isFromMe,
        ),
      );
    });
  }
}

final whatsappHooksControllerProvider =
    AsyncNotifierProvider<WhatsappHooksController, WhatsappHookState>(
      WhatsappHooksController.new,
    );

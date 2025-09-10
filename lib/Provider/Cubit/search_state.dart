abstract class SearchState{}

class SearchInitalState extends SearchState{}

class SearchLoadingState extends SearchState{}

class SearchLoadedState extends SearchState{
  String res;
  SearchLoadedState({required this.res});
}

class SearchErrorState extends SearchState{
  String errorMsg;
  SearchErrorState({required this.errorMsg});
}


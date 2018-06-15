#ifndef dplyr_train_h
#define dplyr_train_h

namespace dplyr {

template <typename Op>
inline void iterate_with_interupts(Op op, int n) {
  int i = 0;
  if (n > DPLYR_MIN_INTERUPT_SIZE) {
    int m = n / DPLYR_INTERUPT_TIMES;
    for (int k = 0; k < DPLYR_INTERUPT_TIMES; k++) {
      for (int j = 0; j < m; j++, i++) op(i);
      Rcpp::checkUserInterrupt();
    }
  }
  for (; i < n; i++) op(i);
}

template <typename Map>
struct push_back_op {
  push_back_op(Map& map_) : map(map_) {}
  inline void operator()(int i) {
    map[i].push_back(i);
  }
  Map& map;
};

template <typename Map>
struct push_back_right_op {
  push_back_right_op(Map& map_) : map(map_) {}
  inline void operator()(int i) {
    map[-i - 1].push_back(-i - 1);
  }
  Map& map;
};


template <typename Map>
inline void train_push_back(Map& map, int n) {
  iterate_with_interupts(push_back_op<Map>(map), n);
}

template <typename Map>
inline void train_push_back_right(Map& map, int n) {
  iterate_with_interupts(push_back_right_op<Map>(map), n);
}

template <typename Set>
inline void train_insert(Set& set, int n) {
  for (int i = 0; i < n; i++) set.insert(i);
}
template <typename Set>
inline void train_insert_right(Set& set, int n) {
  for (int i = 0; i < n; i++) set.insert(-i - 1);
}

}
#endif

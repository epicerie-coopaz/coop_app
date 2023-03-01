int getSortCoef(String key, Map<String, int> toggleSorts) {
  int coef = toggleSorts[key] ?? 1;
  return coef;
}

Map<String, int> resetCoef(String key, Map<String, int> toggleSorts) {
  toggleSorts[key] = (toggleSorts[key] ?? 1) * -1;
  for (String k in toggleSorts.keys) {
    if (k != key) {
      toggleSorts[k] = 1;
    }
  }
  return toggleSorts;
}

T? tryElementAt<T>(List<T> list, int index) {
  try {
    return list.elementAt(index);
  } on RangeError {
    return null;
  }
}

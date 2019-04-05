use "collections"

class LRUNode [K: (Hashable #read & Equatable[K] #read), V: V]
  var value: V
  var next: (K | None)
  var prev: (K | None)
  new _create(key': K, next': (K | None) = None, prev': (K | None) = None)
    key = key'
    next = next'
    prev = prev'

class LRU [K: (Hashable #read & Equatable[K] #read), V: V]
  let _cache : Map[K, LRUNode]
  let _size : USize
  let _start: (LRUNode[K, V] | None) = None
  let _end: (LRUNode[K, V] | None) = None

  new create(size: USize) =>
    _size = size
    _cache = Map[K, V](size)

  fun box apply(key: String): V ? =>
    let node : LRUNode = _cache(key)?
    _move(key)
    node.value

  fun ref _move(node: LRUNode) =>
    if (_start == None) then // Empty List
      _start = node
      _end = _start
    elseif (_start == node) then // Node is the mru
      return
    elseif (_start == _end) then // List has one node
      node.next = _start
      _start.prev = node
      _end = _start
      _start = node
    elseif (_end == node) then // Node is the lru
      _end = node.prev
      _end.next = None
      node.next = _start
      node.prev = Node
      _start.prev = node
      _start = node
    else // Node is in the middle somewhere
      node.prev.next = node.next
      node.next.prev = node.prev
      node.next = _start
      node.prev = None
      _start = node
    end

  fun ref update(key: String, value: A) =>
    var node : LRUNode
    try
      node =  _cache(key)
      node.value = value
      _move(node)
    else
      node = LRUNode[A]._create(value)
      if _cache.size() == _size then
        _tail = _tail.prev
        try
          _cache.remove(_tail.next)?
        end
        _tail.next = None
      end
      _move(node)
    end

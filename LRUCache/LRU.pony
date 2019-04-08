use "collections"
use "ponytest"

class LRUNode [K: (Hashable #read & Equatable[K] #read), V: V]
  var value: V
  var next: (K | None)
  var prev: (K | None)
  new _create(value': V, next': (K | None) = None, prev': (K | None) = None) =>
    value = consume value'
    next = next'
    prev = prev'

class LRUCache [K: (Hashable #read & Equatable[K] #read), V: V]
  let _cache : Map[K, LRUNode[K, V]]
  let _size : USize
  var _start: (K | None) = None
  var _end: (K | None) = None
  var _t: TestHelper
  new create(size': USize, t: TestHelper) =>
    _size = size'
    _cache = Map[K, LRUNode[K, V]](_size)
    _t = t

  fun ref apply(key: K): (V | None) =>
    try
      let node : LRUNode[K, V] = _cache(key)?
      _move(key)
      node.value
    else
      None
    end

  fun ref remove(key: K) =>
    try
      let node: LRUNode[K,V] = _cache(key)?
      match node.prev
        | None => // Node is the _start of the list
          match node.next
            | None => // List has only one node
              _cache.remove(key)?
              _start = None
              _end = None
            | let next: K =>
              _cache(next)?.prev = None
              _start = next
              _cache.remove(key)?
          end
        | let prev: K => //Node is not at the _start
          match node.next
            | None => // Node is the _end of the list
              _cache(prev)?.next = None
              _end = prev
              _cache.remove(key)?
            | let next: K => // Node is in the middle of the list
              _cache(next)?.prev = prev
              _cache(prev)?.next = next
              _cache.remove(key)?
          end
      end
    else
      return
    end
  fun ref _move(key: K) =>
    try
      match _start
        | None => // Empty List
          _start = key
          _end = _start
        | let start: K =>
          if (start == key) then // Node is the mru
            return
          end
          match _end
            | None => return
            | let ennd: K =>
              if (start == ennd) then // List has one node
                let node : LRUNode[K, V] = _cache(key)?
                node.next = _start
                _cache(start)?.prev = key
                _end = _start
                _start = key
              elseif (ennd == key) then // Node is the lru
                let node : LRUNode[K, V] = _cache(key)?
                _end = node.prev
                _cache(ennd)?.next = None
                node.next = _start
                node.prev = None
                _cache(start)?.prev = key
                _start = key
              else // Node is in the middle somewhere or brand new
                let node : LRUNode[K, V] = _cache(key)?
                match node.prev
                  | let prev: K =>
                    _cache(prev)?.next = node.next
                end
                match node.next
                | None => //Node is new in the list
                    node.next = _start
                    _cache(start)?.prev = key
                    _start = key
                  | let next: K => //Node is definately in the middle
                    _cache(next)?.prev = node.prev
                end
                node.next = _start
                node.prev = None
                _start = key
              end
          end
      end
    else
      return
    end

  fun ref update(key: K, value: V) =>
    var node : (LRUNode[K, V] | None) = try _cache(key)? else None end
    // Add a new node if none exists already
    match node
      | None =>
        node = LRUNode[K, V]._create(consume value)
      | let node' : LRUNode[K, V] =>
        node'.value = consume value
    end
    // Cache Ejection
    if _cache.size() == _size then
      match _end
        | let ennd: K =>
          try
            let endNode = _cache(ennd)?
            match endNode.prev
              | None => // We are at the end and its equal to the start
                _end = _start
                try
                  _cache.remove(ennd)?
                  _end = None
                  _start = _end
                else
                  return
                end
              | let newEnd: K =>
                endNode.next = None
                _end = newEnd
                try
                  _cache.remove(ennd)?
                else
                  return
                end
            end
          else
            return
          end
        | None => return  // This is a Cache with no space
      end
    end
    // Update its value in the map
    match node
      | let node' : LRUNode[K, V] =>
        _cache(key) = node'
        _move(key)
    end
  fun contains(key: K): Bool =>
    _cache.contains(key)
  fun size() : USize =>
    _cache.size()
  fun capacity() : USize =>
    _size

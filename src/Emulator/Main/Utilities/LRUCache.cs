//
// Copyright (c) 2010-2018 Antmicro
// Copyright (c) 2011-2015 Realtime Embedded
//
// This file is licensed under the MIT License.
// Full license text is available in 'licenses/MIT.txt'.
//
using System.Collections.Generic;

namespace Antmicro.Renode.Utilities
{
    public class LRUCache<TKey, TVal>
    {
        public LRUCache(int limit)
        {
            this.limit = limit;

            values = new Dictionary<TKey, CacheItem>();
            ordering = new LinkedList<TKey>();
            locker = new object();
        }

        public bool TryGetValue(TKey key, out TVal value)
        {
            lock(locker)
            {
                CacheItem item;
                if(values.TryGetValue(key, out item))
                {
                    ordering.Remove(item.Position);
                    ordering.AddFirst(item.Position);

                    value = item.Value;
                    return true;
                }

                value = default(TVal);
                return false;
            }
        }

        public void Add(TKey key, TVal value)
        {
            lock(locker)
            {
                var node = ordering.AddFirst(key);
                values[key] = new CacheItem { Position = node, Value = value };

                if(ordering.Count > limit)
                {
                    values.Remove(ordering.Last.Value);
                    ordering.RemoveLast();
                }
            }
        }

        public void Invalidate()
        {
            lock(locker)
            {
                values.Clear();
                ordering.Clear();
            }
        }

        private readonly object locker;
        private readonly int limit;
        private readonly Dictionary<TKey, CacheItem> values;
        private readonly LinkedList<TKey> ordering;

        private struct CacheItem
        {
            public TVal Value;
            public LinkedListNode<TKey> Position;
        }
    }
}


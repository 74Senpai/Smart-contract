// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// ---------------------------
// Structs
// ---------------------------
// Thay 'address seller' bằng 'string sellerName'
struct Product {
    string nameProduct;
    uint price;
    uint quantity;
    string sellerName; // Tên người bán (dùng string cho trực quan)
}

struct Order {
    string nameProduct;
    uint price;
    uint quantity;
}

// ---------------------------
// Contract quản lý Sản phẩm Đa Người bán (Multi-Seller Product Manager)
// ---------------------------
contract StoresManager {
    mapping(string => Product) private products;
    string[] private productNames;

    // Mapping mới: Tên Người bán (string) => Danh sách Tên Sản phẩm mà họ sở hữu (Đã thay đổi từ address)
    mapping(string => string[]) private sellerProductNames;

    // Lịch sử mua hàng: Tên Người mua (string) => Danh sách Đơn hàng
    mapping(string => Order[]) private userPurchases;

    //Hàm tiện ích nội bộ
    function compareStrings(
        string memory _a,
        string memory _b
    ) internal pure returns (bool) {
        return
            keccak256(abi.encodePacked(_a)) == keccak256(abi.encodePacked(_b));
    }

    // ---------------------------
    // Các hàm Quản lý Sản phẩm
    // ---------------------------

    // Thêm sản phẩm. Yêu cầu thêm _sellerName (tên người bán)
    function addProduct(
        string memory _sellerName,
        string memory _nameProduct,
        uint _price,
        uint _quantity
    ) external {
        require(
            bytes(_nameProduct).length > 0,
            "Ten san pham khong duoc de trong"
        );
        require(
            bytes(_sellerName).length > 0,
            "Ten nguoi ban khong duoc de trong"
        );

        Product storage prod = products[_nameProduct];

        require(
            bytes(prod.nameProduct).length == 0,
            "San pham da ton tai, khong the them moi. Vui long dung ham update."
        );

        products[_nameProduct] = Product(
            _nameProduct,
            _price,
            _quantity,
            _sellerName
        );

        productNames.push(_nameProduct);
        sellerProductNames[_sellerName].push(_nameProduct);
    }

    // Cập nhật giá. Yêu cầu thêm _sellerName để xác thực
    function updatePrice(
        string memory _sellerName,
        string memory _nameProduct,
        uint _newPrice
    ) external {
        Product storage prod = products[_nameProduct];

        require(bytes(prod.nameProduct).length != 0, "Ko tim thay san pham");

        require(
            compareStrings(prod.sellerName, _sellerName),
            "Ko co quyen thay doi gia"
        );

        prod.price = _newPrice;
    }

    // Lấy danh sách sản phẩm thuộc về người bán (dùng tên)
    function getProductsBySeller(
        string memory _sellerName
    ) external view returns (Product[] memory) {
        string[] memory names = sellerProductNames[_sellerName];
        Product[] memory sellerProducts = new Product[](names.length);

        for (uint i = 0; i < names.length; i++) {
            sellerProducts[i] = products[names[i]];
        }
        return sellerProducts;
    }

    function getProductInfo(
        string memory _nameProduct
    )
        external
        view
        returns (uint price, uint quantity, string memory sellerName)
    {
        Product storage prod = products[_nameProduct];
        require(bytes(prod.nameProduct).length != 0, "Ko tim thay san pham");
        return (prod.price, prod.quantity, prod.sellerName);
    }

    function getAllProducts() external view returns (Product[] memory) {
        Product[] memory allProducts = new Product[](productNames.length);

        for (uint i = 0; i < productNames.length; i++) {
            string memory name = productNames[i];
            allProducts[i] = products[name];
        }
        return allProducts;
    }

    // Người dùng mua sản phẩm. Dùng _username cho trực quan.
    function buyProduct(
        string memory _username,
        string memory _nameProduct,
        uint _quantity
    ) external {
        Product storage prod = products[_nameProduct];

        require(bytes(prod.nameProduct).length != 0, "Ko tim thay san pham");
        require(prod.quantity >= _quantity, "Ton kh khong du de mua");

        // Giảm số lượng tồn kho
        prod.quantity -= _quantity;

        // Lưu lịch sử mua hàng với _username (string)
        userPurchases[_username].push(
            Order({
                nameProduct: _nameProduct,
                price: prod.price,
                quantity: _quantity
            })
        );
    }

    // Xem danh sách sản phẩm đã mua (dùng tên người mua)
    function getPurchaseHistory(
        string memory _username
    ) external view returns (Order[] memory) {
        return userPurchases[_username];
    }
}

<?php

namespace AppBundle\Repository;

use AppBundle\Entity\Category;

/**
 * CategoryRepository
 *
 * This class was generated by the Doctrine ORM. Add your own custom
 * repository methods below.
 */
class CategoryRepository extends \Doctrine\ORM\EntityRepository
{

    public function incrementCount(Category $category) {
        return $this->updateCount($category, " + 1");
    }

    public function decrementCount(Category $category) {
        return $this->updateCount($category, " - 1");
    }

    private function updateCount(Category $category, $direction)
    {
        $this->createQueryBuilder("c")
            ->update("AppBundle:Category", "c")
            ->set("c.postCount", "c.postCount $direction")
            ->where("c = :category")
            ->setParameter('category', $category)
            ->getQuery()
            ->execute();
        return $this;
    }

}
